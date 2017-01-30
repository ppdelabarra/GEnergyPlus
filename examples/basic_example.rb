require_relative '../lib/genergyplus' #this should become "   require 'rbplus'   "

model = EPlusModel.new("8.6.0")

# add zones
model.add("zone",{"name" => "Zone number 1", "multiplier" => 2})
model.add("zone",{"name" => "Zone number 2", "x origin" => 31})


# define use
early = "8:00"
late = "18:00"
lunch = "13:30"

###################################
## DEFINE SOME USEFUL SCHEDULES
###################################
always_on_schedule = model.add_constant_schedule("Always on", 1.0)

###################################
## DEFINE PEOPLE
###################################

#define activity schedule
activity_level = EPlusModel::People.heat_gain_per_person("Writing")
abort "Activity level was not found in the database" if not activity_level
activity_level_schedule = model.add_constant_schedule("people working", activity_level)

#define number of people
occupancy_schedule = model.add_default_office_occupation_schedule("Occupancy schedule", early, late, lunch)


###################################
## DEFINE LIGHTS
###################################

#define light types
light_parameters = EPlusModel::Lights.lamp_data("Surface Mounted, T5H0")
abort "Light data not found on database" if not light_parameters

#define behavior
lighting_schedule = model.add_default_office_lighting_schedule("Lighting schedule", early, late)


###################################
## DEFINE INFILTRATION
###################################
infiltration_coefficients = EPlusModel::Infiltration.get_coefficients("DesignFlowRate:BLAST")
abort "Infiltration Coefficients not found on database" if not infiltration_coefficients

###################################
## DEFINE CONSTRUCTIONS
###################################
thermal_mass_material = model.add("Material", { 
    "name" => "Concrete", 
    "Roughness" => "Rough",
    "Thickness" => 0.15,
    "Conductivity" => 1.63,
    "Density" => 2400,
    "Specific heat" => 750,    
})
internal_mass_construction = model.add_construction("Internal Mass Construction", [thermal_mass_material])

###################################
## APPLY THESE TO ZONES
###################################


model["zone"].each{|zone| 
    zone.set_occupancy("people/area",0.1, occupancy_schedule, activity_level_schedule, false)
    zone.set_lights("Watts/area",12, lighting_schedule, light_parameters)
    zone.set_electric_equipment("Watts/person",100, occupancy_schedule, false)
    zone.set_design_flow_rate_infiltration("AirChanges/Hour", 1.5, always_on_schedule, infiltration_coefficients)
    zone.set_design_flow_rate_ventilation("Flow/Person", 0.02, lighting_schedule, false)    
    zone.set_thermal_mass(internal_mass_construction,2.0, false)
    zone.set_thermal_mass(internal_mass_construction,2.0, {"name" => "another thermal mass"})
}



model.print # 