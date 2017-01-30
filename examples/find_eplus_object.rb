require_relative '../lib/genergyplus' #this should become "   require 'rbplus'   "


query = ARGV[0] ? ARGV[0] : ""
model = EPlusModel.new("8.6.0")
objects = model.find(query)

warn "#{objects.length} Objects found!"

objects.each{|o|     
    puts o
    model.help(o) 
}