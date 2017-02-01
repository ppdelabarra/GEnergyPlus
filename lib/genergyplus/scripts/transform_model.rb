module EPlusModel
    class Model
        
        # Loads all the geometry present on a certain file into the model.
        # It does not import loads, CONSTRUCTIONS, HVAC, or other elements.
        #
        # If 'force required' is set to 'TRUE' in the 'other options' Hash input, 
        # required objects that are not in the object_type_array will be 
        # imported anyway.
        #
        # @author Germán Molina    
        # @param idf_file [String] The file whose geometry will be imported
        # @param other_options [Hash] other options
        # @return [Model] The model itself
        def get_geometry_from_file(idf_file, other_options)      
            all_geometry = EPlusModel::Family.get_family_members("All Geometry")
            self.add_from_file(idf_file, all_geometry, other_options)
            return self
        end

        
        # Assign a construction to all exterior window objects        
        #
        # @author Germán Molina    
        # @param construction [EnergyPlusObject] The construction to be assigned
        # @return [Model] The model itself
        def set_exterior_windows_construction(construction)
            exterior_window_objects = EPlusModel::Family.get_family_members("Exterior Windows")
            exterior_window_objects.each{|object_type|
                object_array = self[object_type]
                next if not object_array
                object_array.each{|object|
                case object_type.downcase
                when "fenestrationsurface:detailed"
                    type = object["Surface Type"].downcase
                    base_surface_name = object["Building Surface Name"]
                    base_surface = self.get_object_by_name(base_surface_name)
                    raise "Base surface '#{base_surface_name}' of #{object.name} '#{object.name}' nof found" if not base_surface
                    next if not (type == "window"and base_surface["Outside Boundary Condition"].downcase == "outdoors"  )
                end
                object["construction name"] = construction.name
                }  
            }
            return self
        end

        # Assign a construction to all interior window objects        
        #
        # @author Germán Molina    
        # @param construction [EnergyPlusObject] The construction to be assigned
        # @return [Model] The model itself
        def set_interior_windows_construction(construction)
            window_objects = EPlusModel::Family.get_family_members("Interior Windows")
            window_objects.each{|object_type|
                object_array = self[object_type]
                next if not object_array
                object_array.each{|object|
                case object_type.downcase
                when "fenestrationsurface:detailed"
                    type = object["Surface Type"].downcase
                    base_surface_name = object["Building Surface Name"]
                    base_surface = self.get_object_by_name(base_surface_name)
                    raise "Base surface '#{base_surface_name}' of #{object.name} '#{object.name}' nof found" if not base_surface
                    next if not (type == "window"and base_surface["Outside Boundary Condition"].downcase == "surface"  )
                end
                object["construction name"] = construction.name
                }  
            }
            return self
        end

        # Assign a construction to all interior wall objects        
        #
        # @author Germán Molina    
        # @param construction [EnergyPlusObject] The construction to be assigned
        # @return [Model] The model itself
        def set_interior_walls_construction(construction)
            wall_objects = EPlusModel::Family.get_family_members("Interior Walls")
            wall_objects.each{|object_type|
                object_array = self[object_type]
                next if not object_array
                object_array.each{|object|
                case object_type.downcase
                when "buildingsurface:detailed"
                    type = object["Surface Type"].downcase            
                    next if not (type == "wall"and object["Outside Boundary Condition"].downcase == "surface"  )
                end
                object["construction name"] = construction.name
                }  
            }
            return self
        end

        # Assign a construction to all exterior wall objects        
        #
        # @author Germán Molina    
        # @param construction [EnergyPlusObject] The construction to be assigned
        # @return [Model] The model itself
        def set_exterior_walls_construction(construction)
            wall_objects = EPlusModel::Family.get_family_members("exterior Walls")
            wall_objects.each{|object_type|
                object_array = self[object_type]
                next if not object_array
                object_array.each{|object|
                case object_type.downcase
                when "buildingsurface:detailed"
                    type = object["Surface Type"].downcase                       
                    next if (not type == "wall" and not object["Outside Boundary Condition Object"] == "outdoors")
                end
                object["construction name"] = construction.name
                }  
            }
            return self
        end

        # Weird name for a method, I know. But what it does is to make adiabatic all floor, 
        # roof and ceiling objects to adiabatic.
        #
        # If a construction is provided with the "assign construction" key in the option tags,
        # these surfaces will be assigned such construction
        #
        # @author Germán Molina    
        # @param options [Hash] options
        # @return [Model] The model itself
        def model_as_storey(options)
            roof_and_ceiling_objects = EPlusModel::Family.get_family_members("Roof and Ceiling")

            roof_and_ceiling_objects.each{ |object_type|
                object_array = self[object_type]
                next if not object_array
                object_array.each{ |object|
                    # assign the construction                
                    case object_type.downcase
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
                        warn "'#{obejct.name}' is already adiabatic. Construction was changed anyway (if asked)."
                    when "floor:adiabatic"
                        warn "'#{obejct.name}' is already adiabatic. Construction was changed anyway (if asked)."
                    else
                        warn "'#{object.name}' could not be made adiabatic because it is a '#{object.name.capitalize}'. Construction was changed anyway (if asked)."
                    end
                    object["construction name"] = options["assign construction"].name if options and options["assign construction"]
                }
            }
            return self
        end

    end
end