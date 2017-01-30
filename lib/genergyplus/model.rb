module EPlusModel

  class Model
    
    def initialize(version)
      @idd_dir = File.join(File.dirname(File.expand_path(__FILE__)), 'idd_files')    
      @version = version.strip
      raise "Fatal: Wrong EnergyPlus version... IDD file not found or not supported" if not File.file? "#{@idd_dir}/#{@version}.idd"
      @idd = IDD.new("#{@idd_dir}/#{@version}.idd")
      @objects = Hash.new

      self.add("version",{"version identifier" => version})
    end

    def get_required_objects_list
      @idd.get_required_objects_list
    end

    def add_from_file(idf_file, object_name_array, other_options )    
      raise "Fatal: File '#{idf_file}' not found" if not File.file? idf_file
      object_name_array.map!{|x| x.downcase} if object_name_array
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
        object_name = object.shift.downcase      
        next if object_name == "version"
        
        object_definition = self.get_definition(object_name)
        
        next if (object_name_array and not object_name_array.include? object_name) and  # and this thing is not in the list
                not (object_definition.required and force_required) 

        #initialize the inputs hash
        inputs = Hash.new
        
        object.each_with_index{|value,index|
            next if value.strip == ""
            field = object_definition.fields[index]          
            inputs[field.name] = value      
            inputs[field.name] = inputs[field.name].to_f if (field.numeric? and not (value.strip.downcase == "autosize" or value.strip.downcase == "autocalculate"))
        } 
        self.add(object_name,inputs)
      }
      return self    
    end

    def add(object_name, inputs)
      object_name.downcase!

      object = get_definition(object_name) #this raises an error if the object does not exist      
      object.check_input(inputs)  #this raises an error if any
      object = object.create(inputs)      

      if object.unique then
        if @objects.key? object_name then
          raise "Trying to replace unique object '#{object_name}'"
        else
          self[object_name] = object     
        end
      else
        if @objects.key? object_name then
          if not self.unique_id?(object.name, object.id) then
            raise "A '#{object_name.capitalize}' called '#{object.id}' already exists"   
          end         
          self[object_name] << object
        else            
          self[object_name] = [object]     
        end
      end
      return object
    end

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

    def save(file_name)
      self.print_to_file(File.open(file_name,'w'))
    end

    def print 
      self.print_to_file($stdout)
    end

    def help(object_name)
      object = @idd[object_name.downcase] #this raises an error if the object does not exist       
      object.help  
    end

    def describe(object_name) 
      object = @idd[object_name.downcase] #this raises an error if the object does not exist       
      puts "!- #{object_name.downcase}"
      puts "!- #{object.memo}"
      puts ""
    end

    def get_definition(object_name)
        @idd[object_name.downcase] #this raises an error if the object does not exist 
    end
    
    def find(query)
      @idd.keys.select{|x| x.downcase.include? query.downcase}      
    end
    
    def [](object_name)
        @objects[object_name.downcase]
    end

    def []=(object_name,object)
        @objects[object_name.downcase] = object
    end

    def get_object_by_id(id)
        @objects.each{|key,object|
            if object.is_a? Array then
                object = object.get_object_by_id(id)
                return object if object
            else
                return value if object.id and object.id.downcase == id.downcase
            end
        }
        return false
    end

    def unique_id?(object_name,id)
      arr = self[object_name]
      return true if arr == nil
      return true if not arr[0].id #if not responds to ID
      return false if arr.map{|x| x.id.downcase}.include? id.downcase 
      return true
    end

    def exists?(object_name,id)
      object = self[object_name]
      return false if object == nil
      if object.is_a? Array then
        object.each{|obj|
          return true if obj.id.downcase == id.downcase
        }
      else
        return true if obj.id.downcase == id.downcase
      end
      return true
    end

    def delete(object_name,id)
      if self[object_name].is_a? Array then
        self[object_name] = self[object_name].select{|x| not x.id.downcase == id.downcase}
      else
        @objects.delete(object_name)
      end
    end


    def get_geometry_from_file(idf_file, other_options)      
      all_geometry = EPlusModel::Family.get_family_members("All Geometry")
      self.add_from_file(idf_file, all_geometry, other_options)
      return self
    end

    def set_exterior_windows_construction(construction)
      exterior_window_objects = EPlusModel::Family.get_family_members("Exterior Windows")
      exterior_window_objects.each{|object_name|
        object_array = self[object_name]
        next if not object_array
        object_array.each{|object|
          case object_name.downcase
          when "fenestrationsurface:detailed"
            type = object["Surface Type"].downcase
            base_surface_id = object["Building Surface Name"]
            base_surface = self.get_object_by_id(base_surface_id)
            raise "Base surface '#{base_surface_id}' of #{object.name} '#{object.id}' nof found" if not base_surface
            next if not (type == "window"and base_surface["Outside Boundary Condition"].downcase == "outdoors"  )
          end
          object["construction name"] = construction.id
        }  
      }
      return self
    end

    def set_interior_windows_construction(construction)
      window_objects = EPlusModel::Family.get_family_members("Interior Windows")
      window_objects.each{|object_name|
        object_array = self[object_name]
        next if not object_array
        object_array.each{|object|
          case object_name.downcase
          when "fenestrationsurface:detailed"
            type = object["Surface Type"].downcase
            base_surface_id = object["Building Surface Name"]
            base_surface = self.get_object_by_id(base_surface_id)
            raise "Base surface '#{base_surface_id}' of #{object.name} '#{object.id}' nof found" if not base_surface
            next if not (type == "window"and base_surface["Outside Boundary Condition"].downcase == "surface"  )
          end
          object["construction name"] = construction.id
        }  
      }
      return self
    end

    def set_interior_walls_construction(construction)
      wall_objects = EPlusModel::Family.get_family_members("Interior Walls")
      wall_objects.each{|object_name|
        object_array = self[object_name]
        next if not object_array
        object_array.each{|object|
          case object_name.downcase
          when "buildingsurface:detailed"
            type = object["Surface Type"].downcase            
            next if not (type == "wall"and object["Outside Boundary Condition"].downcase == "surface"  )
          end
          object["construction name"] = construction.id
        }  
      }
      return self
    end

    def set_exterior_walls_construction(construction)
      wall_objects = EPlusModel::Family.get_family_members("exterior Walls")
      wall_objects.each{|object_name|
        object_array = self[object_name]
        next if not object_array
        object_array.each{|object|
          case object_name.downcase
          when "buildingsurface:detailed"
            type = object["Surface Type"].downcase                       
            next if (not type == "wall" and not object["Outside Boundary Condition Object"] == "outdoors")
          end
          object["construction name"] = construction.id
        }  
      }
      return self
    end

    def model_as_storey(options)
        roof_and_ceiling_objects = EPlusModel::Family.get_family_members("Roof and Ceiling")

        roof_and_ceiling_objects.each{ |object_name|
            object_array = self[object_name]
            next if not object_array
            object_array.each{ |object|
                # assign the construction                
                case object_name.downcase
                when "buildingsurface:detailed"
                    type = object["Surface Type"].downcase
                    next if not ["floor", "roof", "ceiling"].include? type
                    object["Outside Boundary Condition"]="Adiabatic"    
                    object["Sun Exposure"]="NoSun"
                    object["Wind Exposure"]="NoWind"        
                    object.delete "Outside Boundary Condition Object"
                when "roofceiling:detailed"
                    object["Outside Boundary Condition"]="Adiabatic"            
                    object.delete "Outside Boundary Condition Object"
                when "floor:detailed"
                    object["Outside Boundary Condition"]="Adiabatic"            
                    object.delete "Outside Boundary Condition Object"
                when "ceiling:adiabatic"
                    warn "'#{obejct.id}' is already adiabatic. Construction was changed anyway."
                when "floor:adiabatic"
                    warn "'#{obejct.id}' is already adiabatic. Construction was changed anyway."
                else
                    warn "'#{object.id}' could not be made adiabatic because it is a '#{object.name.capitalize}'. Construction was changed anyway."
                end
                object["construction name"] = options["assign construction"].id if options
            }
        }
        return self
    end

    def add_branch_list(name,branch_array)
            inputs = { "name" => name }
            branch_array.each_with_index{|branch,index|
                inputs["Branch #{index+1} Name"]=branch.id
            }
            self.add("branchlist",inputs)
        end

        def add_connector_list(name,connector_array)
            inputs = { "name" => name }
            connector_array.each_with_index{|connector,index|
                inputs["Connector #{index + 1} Object Type"]=connector.name
                inputs["Connector #{index + 1} name"]=connector.id
            }
            self.add("ConnectorList",inputs)
        end

        def add_splitter(name,inlet_branch,outlet_branch_array)
            inputs = { "name" => name }
            inputs["Inlet branch name"] = inlet_branch.id
            outlet_branch_array.each_with_index{|branch,index|
                inputs["Outlet Branch #{index+1} Name"] = branch.id
            }
            self.add("Connector:Splitter", inputs)
        end

        def add_mixer(name,outlet_branch,inlet_branch_array)
            inputs = { "name" => name }
            inputs["Outlet branch name"] = outlet_branch.id
            inlet_branch_array.each_with_index{|branch,index|
                inputs["Inlet Branch #{index+1} Name"] = branch.id
            }
            self.add("Connector:Mixer", inputs)
        end

  end #end of class

end