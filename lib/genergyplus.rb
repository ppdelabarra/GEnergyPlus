require_relative "genergyplus/version"
require_relative "genergyplus/array"
require_relative "genergyplus/field"
require_relative "genergyplus/idd"
require_relative "genergyplus/model"
require_relative "genergyplus/object"
require_relative "genergyplus/vector3d"


require_relative "genergyplus/generators/zone"
require_relative "genergyplus/generators/schedules"
require_relative "genergyplus/generators/construction"
require_relative "genergyplus/generators/connector"

require_relative "genergyplus/scripts/transform_model"

require_relative "genergyplus/databases/family"
require_relative "genergyplus/databases/infiltration"
require_relative "genergyplus/databases/occupancy"
require_relative "genergyplus/databases/lights"


# Main module
module EPlusModel

  # Main module of the gem. It only allows handling one model at a time.

  # The model. It is unique for the module, so only one 
  # model may be modified at a time.
  @@model=false



  # References the model
  #
  # @author Germán Molina
  # @return [Model] The model
  def self.model
    @@model
  end




  # Creates a new model with a certain version.
  #
  # @author Germán Molina
  # @param version [String] The version of EnergyPlus to be used... 8.6.0 is the only one supported so far.
  # @return [Model] The model
  def self.new(version)
    @@model = Model.new(version)        
    return @@model
  end

  # Used when creating a model from an existing file. This returns an array
  # of strings, each of which represent an object.
  #
  # @author Germán Molina
  # @param idf_file [String] The name of the IDF file to read
  # @return [<String>] An array of string
  def self.pre_process_file(idf_file)
    #Pre process file
    raw_file = File.readlines(idf_file)
    file = raw_file.select{|line| not line.strip.start_with? "!"}
    file.map!{|x| x.split("!").shift.strip} #remove comments
    file.join.split(";") # Put the whole file togeter, and pack into objects
  end    

  # Finds the version of an existing IDF file (provided pre-procssed).
  # If it is not there, 8.6.0 will be assigned
  #
  # @author Germán Molina
  # @param file [<String>] An array of strings representing the object.
  # @return [String] The version in the file.
  def self.get_version(file)
    version = file.select{|x| x.downcase.start_with? "version"}.shift    
      if not version then
        warn "IDF file does not have version identifier... asigning '8.6.0'"
        version = "version,8.6.0"
      end
      version = version.split(",").pop
      version += ".0" if version.split(".").length == 2 #Transforms "8.6"" in "8.6.0"
      return version
  end

  # Reads an IDF file and returns a model with all its data.
  # 
  # @author Germán Molina
  # @param idf_file [String] The name of the IDF file
  # @return [Model] The model 
  def self.new_from_file(idf_file)
    file = self.pre_process_file(idf_file)
    version = self.get_version(file)
    model = self.new(version)
    model.add_from_file(idf_file, false, false ) 
    return model 
  end




end #end of module

