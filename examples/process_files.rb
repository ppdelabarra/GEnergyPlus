require_relative "../lib/rbplus"

if ARGV.length != 1
    warn "USAGE: ruby read_file.rb 'NAME_OF_FILE_TO_READ'"
end

idf_file=ARGV[0]

# Create a file
model = EPlusModel.new("8.6.0")  

# Load geometry from a certain file
model.get_geometry_from_file(idf_file, false )  

# Turn all ceilings and floors into adiabatic surfaces... in order to model one storey in the whole building
floor_interzone_material = model.add("Material", { 
    "name" => "Concrete", 
    "Roughness" => "Rough",
    "Thickness" => 0.15,
    "Conductivity" => 1.63,
    "Density" => 2400,
    "Specific heat" => 750,    
})
floor_ceiling_construction = model.add_construction("Floor / Ceiling construction", [floor_interzone_material])
options = { "assign construction" => floor_ceiling_construction }
model.model_as_storey(options)

# Add some other things from another file. 
# Of course, the variable 'idf_file' should change... it is up yo you how 
# to define those.
# model.add_from_file(idf_file, ["Material"], false )  #EPlusModel.new_from_file(ARGV[0])

model.print