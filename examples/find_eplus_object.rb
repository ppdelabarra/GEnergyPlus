require_relative '../lib/rbplus' #this should become "   require 'rbplus'   "


query = ARGV[0] ? ARGV[0] : ""
model = EPlusModel.new("8.6.0")
puts model.find(query)
