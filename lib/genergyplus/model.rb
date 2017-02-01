module EPlusModel

  # This is the model class, which is the main object we deal with on the scripts.

  class Model
    
    # Initializes a new, and empty, Model object. It automatically adds the given version.
    #
    # @author Germán Molina
    # @param version [String] the version in format '8.6.0'.
    # @return [Model] The model itself
    def initialize(version)
      @idd_dir = File.join(File.dirname(File.expand_path(__FILE__)), 'idd_files')    
      @version = version.strip
      raise "Fatal: Wrong EnergyPlus version... IDD file not found or not supported" if not File.file? "#{@idd_dir}/#{@version}.idd"
      @idd = IDD.new("#{@idd_dir}/#{@version}.idd")
      @objects = Hash.new

      self.add("version",{"version identifier" => version})
      return self
    end

    # Returns the Input Data Dictionary object of the model.
    #
    # @author Germán Molina
    # @return [IDD] The input data Dictionary object
    def get_required_objects_list
      @idd.get_required_objects_list
    end

    # Adds a whole set of objects types from an existing file into the model.
    #
    # If 'force required' is set to 'TRUE' in the 'other options' Hash input, 
    # required objects that are not in the object_type_array will be 
    # imported anyway.
    #
    # @author Germán Molina
    # @param idf_file [String] The IDF file to read
    # @param object_type_array [<String>] An array with the types of objects to read
    # @param other_options [Hash] Other options
    # @return [Model] The model itself
    def add_from_file(idf_file, object_type_array, other_options )    
      raise "Fatal: File '#{idf_file}' not found" if not File.file? idf_file
      object_type_array.map!{|x| x.downcase} if object_type_array
      other_options = Hash.new if not other_options

      # Default options
      force_required = false

      # process other_options
      force_required = other_options["force required"] if other_options.key? "force required"

      #pre process file
      file = EPlusModel.pre_process_file(idf_file)
      
      #Add objects in file to model     
      file.each{|object|
        object = object.split(",")
        object_type = object.shift.downcase      
        next if object_type == "version"
        
        object_definition = self.get_definition(object_type)
        
        next if (object_type_array and not object_type_array.include? object_type) and  # and this thing is not in the list
                not (object_definition.required and force_required) 

        #initialize the inputs hash
        inputs = Hash.new
        
        object.each_with_index{|value,index|
            next if value.strip == ""
            field = object_definition.fields[index]          
            inputs[field.name] = value      
            inputs[field.name] = inputs[field.name].to_f if (field.numeric? and not (value.strip.downcase == "autosize" or value.strip.downcase == "autocalculate"))
        } 
        self.add(object_type,inputs)
      }
      return self    
    end

    # The basic method for adding objects to the model. 
    #
    # @author Germán Molina
    # @return [EnergyPlusObject] The added object
    # @param object_type [String] The type of the object to add
    # @param inputs [Hash] The arguments to the obejct 
    def add(object_type, inputs)
      object_type.downcase!

      object = get_definition(object_type) #this raises an error if the object does not exist      
      object.check_input(inputs)  #this raises an error if any
      object = object.create(inputs)      

      if object.unique then
        if @objects.key? object_type then
          raise "Trying to replace unique object '#{object_type}'"
        else
          self[object_type] = object     
        end
      else
        if @objects.key? object_type then
          if not self.unique_name?(object.type, object.name) then
            raise "A '#{object_type.capitalize}' called '#{object.name}' already exists"   
          end         
          self[object_type] << object
        else            
          self[object_type] = [object]     
        end
      end
      return object
    end


    # Prints the model into a file, which may be the "STDOUT"
    #
    # @author Germán Molina
    # @param file [File] The file to print the model at
    def print_to_file(file)
      @objects.each{|key,value|    
        if value.is_a? Array then
          value.each{|i| 
            i.print(file)
            file.puts ""
          }                  
        else    
          value.print(file)
        end
        file.puts ""        
      }
      file.close
    end

    # Writes the model into a text file
    #
    # @author Germán Molina
    # @param file_name [String] The name of the file   
    def save(file_name)
      self.print_to_file(File.open(file_name,'w'))
    end

    # Prints the model into the standard output
    #
    # @author Germán Molina
    def print 
      self.print_to_file($stdout)
    end

    # Prints data related to a certain object type to the standard output.
    #
    # @author Germán Molina
    # @param object_type [String] The object type
    def help(object_type)
      object = @idd[object_type.downcase] #this raises an error if the object does not exist       
      object.help  
    end

    # Prints data related to a certain object type to the standard output.
    #
    # @author Germán Molina
    # @param object_type [String] The object type
    def describe(object_type) 
      object = @idd[object_type.downcase] #this raises an error if the object does not exist       
      puts "!- #{object_type.downcase}"
      puts "!- #{object.memo}"
      puts ""
    end

    # Retrieves the definition of the object type, wich is just an object without any 
    # arguments (i.e. all fields are empty)
    #
    # @author Germán Molina    
    # @param object_type [String] The object type
    # @return [EnergyPlusObject] The object definition (an empty object of that type)
    def get_definition(object_type)
        @idd[object_type.downcase] #this raises an error if the object does not exist 
    end
    
    # Finds for a certain word in the Input Data Dictionary of the model.
    # This is very useful for searching IDD items (avoiding reading the 
    # InputOutput documentation)
    #
    # @author Germán Molina    
    # @param query [String] The word to search, such as "zone" or "HVAC"
    # @return [<String>] An array of names that match the query
    def find(query)
      @idd.keys.select{|x| x.downcase.include? query.downcase}      
    end
    
    # Retrieves the object of given type in the model. 
    #
    # If the object is not unique (i.e. the 'version' obejct is
    # unique, but the 'SurfaceDetailed' is not), an array of objects 
    # is returned. This is due to the structure used to store data in the 
    # model. 
    #
    # If the model does not have any, "nil" will be returned
    #
    # @author Germán Molina    
    # @param object_type [String] The object type
    # @return [<EnergyPlusObject>] An array of obejcts or a single object, depending on the type.
    def [](object_type)
        @objects[object_type.downcase]
    end

    # Sets an object (or array of objects) to a certain model. This new obejct will
    # replace the old one.
    #
    # @author Germán Molina    
    # @param object_type [String] The object type
    # @param object [EnergyPlusObject] The object of array of objects
    def []=(object_type,object)      
        @objects[object_type.downcase] = object
    end

    # Finds an object inside the model by name (which are unique)
    #
    # @author Germán Molina    
    # @param name [String] The name of the object to find
    # @return [EnergyPlusObject] The found object, if found. False if not.
    def get_object_by_name(name)
        @objects.each{|key,object|
            if object.is_a? Array then
                object = object.get_object_by_name(name)
                return object if object
            else
                return value if object.name and object.name.downcase == name.downcase
            end
        }
        return false
    end

    # Names of objects should be unique within an object type. Well, this method
    # allows checking if the name exists already or not in the model.
    #
    # @author Germán Molina    
    # @param object_type [String] The object type
    # @param name [String] The name to checking
    # @return [Boolean] True if unique, false if not
    def unique_name?(object_type,name)
      arr = self[object_type]
      return true if arr == nil
      return true if not arr[0].name #if not responds to name
      return false if arr.map{|x| x.name.downcase}.include? name.downcase 
      return true
    end

    # Checks if an object of a certain name and type exist in the model.
    #
    # @author Germán Molina    
    # @param object_type [String] The object type
    # @param name [String] The name to checking
    # @return [Boolean] True if it exists, false if not
    def exists?(object_type,name)
      object = self[object_type]
      return false if object == nil
      if object.is_a? Array then
        object.each{|obj|
          return true if obj.name.downcase == name.downcase
        }
      else
        return true if obj.name.downcase == name.downcase
      end
      return true
    end

    # Delete an object of a certain type and name.
    #
    # @author Germán Molina    
    # @param object_type [String] The object type
    # @param name [String] The name to checking    
    def delete(object_type,name)
      if self[object_type].is_a? Array then
        self[object_type] = self[object_type].select{|x| not x.name.downcase == name.downcase}
      else
        @objects.delete(object_type)
      end
    end

    

  end #end of class

end