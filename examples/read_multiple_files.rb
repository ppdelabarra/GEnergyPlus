require_relative "../lib/rbplus"

if ARGV.length != 1
    warn "USAGE: ruby read_file.rb 'NAME_OF_FILE_TO_READ'"
end

idf_file=ARGV[0]

# Create a file
model = EPlusModel.new("8.6.0")  

# Add some of the things in a certain file
model.add_from_file(idf_file, ["GlobalGeometryRules"], false )  #EPlusModel.new_from_file(ARGV[0])

# Add some other things from another file. 
# Of course, the variable 'idf_file' should change... it is up yo you how 
# to define those.
model.add_from_file(idf_file, ["Material"], false )  #EPlusModel.new_from_file(ARGV[0])

model.print