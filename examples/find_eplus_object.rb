require_relative '../lib/rbplus' #this should become "   require 'rbplus'   "


query = ARGV[0] ? ARGV[0] : ""
model = EPlusModel.new("8.6.0")
objects = model.find(query)

warn "#{objects.length} Objects found!"

objects.each{|o|     
    puts o
    model.help(o) 
}