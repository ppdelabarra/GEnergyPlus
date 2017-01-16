require_relative '../lib/rbplus' #this should become "   require 'rbplus'   "

model = EPlusModel.new("8.6.0")
model.add("version",{"version identifier" => "8.6.0"})
model.add("zone",{"name" => "Zone number 1"})
model.add("building",Hash.new{})
model.add("zone",{"name" => "Zone number 2"})

model.print