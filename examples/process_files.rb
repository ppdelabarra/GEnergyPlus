require_relative "../lib/genergyplus"

if ARGV.length != 1
    warn "USAGE: ruby read_file.rb 'NAME_OF_FILE_TO_READ'"
end

idf_file=ARGV[0]

# Create a file
model = EPlusModel.new("8.6.0")  
model.add("Building",Hash.new) #Include the default building
model.add("RunPeriod",{
      "Name" => "default_period",
      "Begin Month" => 1,
      "Begin day of month" => 1,
      "End Month" => 12,
      "End day of month" => 31
    }) #Include the default building
    
# set up simulation period
model["RunPeriod"][0]["End Month"]=1
model["RunPeriod"][0]["End Day of Month"]=3

model.add("SimulationControl",{
    "Do zone sizing calculation" => "Yes"
})

model.add("sizingperiod:WeatherFileDays",{
    "name" => "sizing period",
    "Begin Month" => 1,
    "Begin day of month" => 1,
    "End Month" => 1,
    "End day of month" => 1
})


model.add("sizingperiod:WeatherFileDays",{
    "name" => "heating sizing period",
    "Begin Month" => 7,
    "Begin day of month" => 1,
    "End Month" => 7,
    "End day of month" => 1
})

# Load geometry from a certain file
model.get_geometry_from_file(idf_file, false )  

# Turn all ceilings and floors into adiabatic surfaces... in order to model one storey in the whole building
floor_interzone_material = model.add("Material", { 
    "name" => "Floor / Ceiling Concrete", 
    "Roughness" => "Rough",
    "Thickness" => 0.15,
    "Conductivity" => 1.63,
    "Density" => 2400,
    "Specific heat" => 750,    
})

floor_ceiling_construction = model.add_construction("Floor / Ceiling construction", [floor_interzone_material])
options = { "assign construction" => floor_ceiling_construction }
model.model_as_storey(options)



exterior_glass = model.add("windowmaterial:glazing",{
    "name" => "exterior glass",
    "Optical Data Type" => "SpectralAverage",
    "thickness" => 0.006, #6mm
    "Solar transmittance at normal incidence" => 0.7,
    "Front side solar reflectance at normal incidence" => 0.07,
    "Back side solar reflectance at normal incidence" => 0.07,
    "Visible transmittance at normal incidence" => 0.7,
    "Front side Visible reflectance at normal incidence" => 0.07,
    "Back side Visible reflectance at normal incidence" => 0.07,        
})

air_gap = model.add("windowmaterial:gas",{
    "name" => "air gap",
    "gas type" => "air",
    "thickness" => 12.0/1000.0, #12mm

})

exterior_window_construction = model.add_construction("Curtain Wall", [exterior_glass, air_gap, exterior_glass])
model.set_exterior_windows_construction(exterior_window_construction)

interior_window_construction = model.add_construction("Interior wall construction", [exterior_glass])
model.set_interior_windows_construction(interior_window_construction)

interior_wall_construction = model.add_construction("interior wall", [floor_interzone_material])
model.set_interior_walls_construction(interior_wall_construction)

exterior_wall_construction = model.add_construction("exterior wall", [floor_interzone_material])
model.set_exterior_walls_construction(exterior_wall_construction)




###############################################
## Add Chiller on Top and fancoils on each zone
###############################################

cooling_setpoint = model.add_constant_schedule("Cooling setpoint", 25)
heating_setpoint = model.add_constant_schedule("Heating setpoint", 18)

always_on = model.add_constant_schedule("Always on", 1)
always_off = model.add_constant_schedule("Always off", 0)

thermostat = model.add("HVACTemplate:thermostat",{
    "name" => "All Zones Thermostat",    
    "Heating Setpoint Schedule Name" => heating_setpoint.id,
    "Cooling Setpoint Schedule Name" => cooling_setpoint.id
})

design_specification_zoneairdistribution = model.add("designspecification:zoneairdistribution",{ "name" => "All zones zoneairdistribution"})
design_specification_outdoorair = model.add("designspecification:outdoorair",{
    "name" => "All Zone designspecificationoutdoorair",
    "Outdoor Air Method" => "Flow/Area"
})

### Add the same for every zone.
model["zone"].each_with_index{|zone,index|
    zone_id = zone.id
    fancoil = model.add("HVACTemplate:zone:Fancoil",{
        "Zone Name" => zone_id,
        "Template Thermostat Name" => thermostat.id,
        "Outdoor Air Method" => "Flow/Zone",
        "Outdoor Air Flow Rate per Zone" => 0,
        "System Availability Schedule Name" => always_on.id,
        "Heating Coil Availability Schedule Name" => always_off.id

    })
}

## Add plant loops
model.add("HVACTemplate:Plant:ChilledWaterLoop",{
    "name" => "Chilled Water Loop",
    "Pump control type" => "Continuous",
    "Chilled water design setpoint" => 7.22,
    "Chilled water pump configuration" => "ConstantPrimaryNoSecondary",    
})

model.add("hvactemplate:plant:chiller",{
    "name" => "chiller",
    "chiller type" => "ElectricReciprocatingChiller",
    #"Capacity" => 123,
    "Nominal Cop" => 3.2,
    "Condenser Type" => "AirCooled",
})

model.add("HVACTemplate:Plant:HotWaterLoop",{
    "name" => "Hot Water Loop",
    "Pump control type" => "Intermittent",
    "Hot water design setpoint" => 80,
    "Hot water pump configuration" => "ConstantFlow",    
})

model.add("HVACTemplate:Plant:Boiler",{
    "name" => "Boiler",
    "Boiler Type" => "HotWaterBoiler",
    "Fuel Type" => "Electricity",
    "Template Plant Loop Type" => "HotWater",
    "capacity" => 2
})



## ASK FOR OUTPUT
report = [

    #"Zone Air Temperature",
    "Chiller Electric Energy",
    #"Facility Total Purchased Electric Energy",

]
report.each{|variable|
    model.add("output:variable",{
        "Variable Name" => variable,
        "Reporting Frequency" => "hourly"
    })
}


#model.add("Output:VariableDictionary",{ "key field" => "IDF" })


model.print