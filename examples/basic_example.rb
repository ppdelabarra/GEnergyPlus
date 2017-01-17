require_relative '../lib/rbplus' #this should become "   require 'rbplus'   "

model = EPlusModel.new("8.6.0")

# add zones
model.add("zone",{"name" => "Zone number 1", "multiplier" => 2})
model.add("zone",{"name" => "Zone number 2", "x origin" => 31})


# define use
early = "8:00"
late = "18:00"
lunch = "13:30"

###################################
## DEFINE PEOPLE
###################################

#define activity schedule
activity_level_schedule_name = "people working"
activity_level = EPlusModel::People.heat_gain_per_person("Writing")
model.add_constant_schedule(activity_level_schedule_name, activity_level)
abort "Activity level was not found in the database" if not activity_level

#define number of people
occupancy_schedule_name = "Occupancy schedule"
model.add_default_office_occupation_schedule(occupancy_schedule_name, early, late, lunch)


###################################
## DEFINE LIGHTS
###################################

#define light types
lighting_schedule_name = "Lighting schedule"
light_parameters = EPlusModel::Lights.lamp_data("Surface Mounted, T5H0")
abort "Light data not found on database" if not light_parameters

#define behavior
model.add_default_office_lighting_schedule(lighting_schedule_name, early, late)



###################################
## APPLY THIS TO ZONES
###################################


model["zone"].each{|zone| 
    zone.set_occupancy("people/area",2, occupancy_schedule_name, activity_level_schedule_name, Hash.new)
    zone.set_lights("Watts/area",12, lighting_schedule_name, light_parameters)
}



model.print