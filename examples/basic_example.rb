require_relative '../lib/rbplus' #this should become "   require 'rbplus'   "

model = EPlusModel.new("8.6.0")
model.add("zone",{"name" => "Zone number 1", "multiplier" => 2})
#model.add("building",Hash.new{})
#model.print

model.add("zone",{"name" => "Zone number 2", "x origin" => 31})

#model["zone"].each{|x| puts x.id}
zone = model.get_object_by_id("zone number 2")

model.add_constant_schedule("always 3", 3)
model.add_default_office_occupation_schedule("Occupancy", "8:12", "19:00","13:30")

zone.set_occupancy("people/area",2, "schedule", "activity_schedule")
zone.set_lights("LightingLevel",22, "schedule", EPlusModel::Lights.lamp_data("Surface Mounted, T5H0"))


model.print