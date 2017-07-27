# GEnergyPlus

GEnergyPlus is a ruby gem that aims helping processing and modifying [EnergyPlus](http://www.energyplus.net) Input Data Files (IDF) by using an object-oriented 
syntax. The motivation behind it is that, while EnergyPlus is an incredibly flexible and powerful Building Energy Performance Simulation engine, it is often hard 
to perform parametric analysis, optimizations or other repetitive tasks. In my particular case, I needed to integrate [Radiance](http://www.radiance-online.org) 
with EnergyPlus, while performing optimizations. This became became a big challenge since Radiance is a Unix-like suite of programs while the second is not.

This library allowed me to write ruby scripts that modified both the EnergyPlus and the Radiance models simultaneously (although this gem only deals with the
EnergyPlus side of the problem), including internal loads, materials and schedules.

The purpose of this gem is to help you modify, programmatically, IDF files in order to perform thousands of simulations for optimization, iteration, parametric
analysis, or whatever you want.


## Installation 

```ruby
gem install genergyplus
```

## Some cool features

- **Supports all EnergyPlus objects:** Generators allows adding some obejcts in an easier and more intuitive way, but every single object within the Input Data Dictionary can be added to the model.
- **Object oriented:** When you change a name or type or parameter of an object, all the referencing objects are automatically updated.
- **Check inputs:** By reading the IDD, GEnergyPlus knows what the boundaries and type of inputs should be given.

## Usage

A powerful feature of GEnergyPlus is that it allows 


```
require 'genergyplus'

 ###################################
 ## Create an EnergyPlus model. 
 ###################################
 # Provide the EnergyPlus version... only 8.6.0 is supported for now.

model = EPlusModel.new("8.6.0")  

 # Or create it based on an existing file

model = EPlusModel.new_from_file('input_file.idf')  

 ###############################################
 ## Use the basic "add" method for adding zones. 
 ###############################################
 # This method can be used for adding any other object present on the Input Data Dictionary by using:
 #      model.add('NAME OF THE OBJECT',HASH WITH THE INFORMATION)  

model.add("zone",{"name" => "Zone number 1", "multiplier" => 2})
model.add("zone",{"name" => "Zone number 2", "x origin" => 31})

 ###################################
 ## define use of the building
 ###################################

early = "8:00"
late = "18:00"
lunch = "13:30"

 ###################################
 ## DEFINE SOME USEFUL SCHEDULES
 ###################################
 # Schedules can be added from the *model.add{'Schedule:compact',{options}}* method, 
 # but some objects, such as constant schedules, may be created in an easier way.
 # We call these methods 'generators' (thus the name 'genergyplus')

always_on_schedule = model.add_constant_schedule("Always on", 1.0)

 ###################################
 ## DEFINE PEOPLE
 ###################################

 # Some values are stored within the library. For example, the metabolic rate of people performing
 # different activities

activity_level = EPlusModel::People.heat_gain_per_person("Writing")
abort "Activity level was not found in the database" if not activity_level #in case there is no Writing object
activity_level_schedule = model.add_constant_schedule("people working", activity_level)

 # Again, use a generator for creating a schedule.

occupancy_schedule = model.add_default_office_occupation_schedule("Occupancy schedule", early, late, lunch)


 ###################################
 ## DEFINE LIGHTS
 ###################################

 # Define light types by getting the data stored in the gem

light_parameters = EPlusModel::Lights.lamp_data("Surface Mounted, T5H0")
abort "Light data not found on database" if not light_parameters

 # Define lighting schedules by using another generator.

lighting_schedule = model.add_default_office_lighting_schedule("Lighting schedule", early, late)


 ###################################
 ## DEFINE INFILTRATION
 ###################################
 
 # Define infiltration by referencing the empirical BLAST constants
infiltration_coefficients = EPlusModel::Infiltration.get_coefficients("DesignFlowRate:BLAST")
abort "Infiltration Coefficients not found on database" if not infiltration_coefficients

 ###################################
 ## DEFINE CONSTRUCTIONS
 ###################################

 # add a new material by using the standard "add" method.
thermal_mass_material = model.add("Material", { 
    "name" => "Concrete", 
    "Roughness" => "Rough",
    "Thickness" => 0.15,
    "Conductivity" => 1.63,
    "Density" => 2400,
    "Specific heat" => 750,    
})

 # Add a construction by using a generator.
internal_mass_construction = model.add_construction("Internal Mass Construction", [thermal_mass_material])

 ###################################
 ## APPLY ALL THESE TO ZONES
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

 ###################################
 ## PRINT AN IDF FILE TO THE CONSOLE.
 ###################################

model.print 

 ###################################
 ## OR SAVE IT TO A FILE
 ###################################

model.save("firstIDFfile.idf")

```
## Development

Feel free to report bugs, include more methods, add generators, useful scripts or whatever you want. Also, extending the libraries is very encouraged, since they increase the quality of the building models and makes it easier to develop them.

Please reference any data that should be referenced (i.e. Data, methods that follow standards, etc.)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ppdelabarra/genergyplus. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [GNU General Public License v.3](https://opensource.org/licenses/GPL-3.0).

