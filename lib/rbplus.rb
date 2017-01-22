require_relative "rbplus/version"
require_relative "rbplus/idd"
require_relative "rbplus/model"
require_relative "rbplus/array"
require_relative "rbplus/zone"
require_relative "rbplus/schedules"
require_relative "rbplus/construction"
require_relative "rbplus/connector"


require_relative "rbplus/databases/family"
require_relative "rbplus/databases/infiltration"
require_relative "rbplus/databases/occupancy"
require_relative "rbplus/databases/lights"


module EPlusModel


  @@model=false

  def self.model
    @@model
  end





  def self.new(version)
    @@model = Model.new(version)        
    return @@model
  end

  def self.pre_process_file(idf_file)
    #Pre process file
    raw_file = File.readlines(idf_file)
    file = raw_file.select{|line| not line.strip.start_with? "!"}
    file.map!{|x| x.split("!").shift.strip} #remove comments
    file.join.split(";") # Put the whole file togeter, and pack into objects
  end    

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

  def self.new_from_file(idf_file)
    file = self.pre_process_file(idf_file)
    version = self.get_version(file)
    model = self.new(version)
    model.add_from_file(idf_file, false, false ) 
    return model 
  end




end #end of module

