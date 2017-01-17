require_relative "rbplus/version"
require_relative "rbplus/idd"
require_relative "rbplus/model"
require_relative "rbplus/array"
require_relative "rbplus/zone"


module EPlusModel


  @@model=false

  def self.model
    @@model
  end





  def self.new(version)
    @@model = Model.new(version)
    return @@model
  end

  def self.new_from_file(idf_file)
    raise "Fatal: File '#{idf_file}' not found" if not File.file? idf_file
    raw_file = File.readlines(idf_file)
    file = raw_file.select{|line| not line.strip.start_with? "!"}
    file.map!{|x| x.split("!").shift.strip} #remove comments
    file = file.join.split(";") # Put the whole file togeter, and pack into objects

    #get version
    version = file.select{|x| x.downcase.start_with? "version"}.shift.split(",").pop
    @@model = Model.new(version)
    
    file.each{|object|
      object = object.split(",")
      object_name = object.shift.downcase
      next if object_name == "version"
      
      #initialize the inputs hash
      inputs = Hash.new
      object_definition = @@model.get_definition(object_name)
      object_definition.fields.each{|field|
        inputs[field.name] = object.shift
        inputs[field.name] = inputs[field.name].to_f if field.numeric?       
      } 
      @@model.add(object_name,inputs)
    }
    return @@model    
  end

end #end of module

