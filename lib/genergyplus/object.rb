module EPlusModel   

    # This is the main Object class... the different objects do not inherit from this one, but actually ARE
    # instances of it. Creating a new class for each object would require creating a huge amount of classes
    # with methods and etc.
    #
    # This simpler way still works well... but remember to verify the kind of object when writing type-specific 
    # methods (i.e. a method that only works for zones)

    class EnergyPlusObject
        attr_accessor :type, :fields, :unique, :memo, :min_fields, :group 
        attr_accessor :format, :required, :fields_as_indicated, :extensible

        # Receives a String with the type (i.e. 'Zone' or 'Schedule:constant').
        # This is saved with its case, but GenergyPlus is usually case insensitive.
        # 
        # This method is rarely used from the scripts, since the object returned
        # is empty. You would usually use the "create" method, which initializes and
        # fills a new object
        #
        # @author Germán Molina
        # @param type [String] The name of the object type
        # @return [EnergyPlusObject] the object created... empty
        def initialize(type)
            @type=type
            @fields= []
            @unique = false
            @memo = ""
            @min_fields = 0
            @group=false;
            @format = false
            @required = false
            @fields_as_indicated = false
            @extensible = false
        end

        # Checks whether the inputs are correct for this specific object.
        # It raises when the input is incorrect.
        #
        # @author Germán Molina
        # @param original_input [Hash] The input object with the options and paramaters
        # @return [Boolean] success
        def check_input(original_input)
            input = Hash.new
            #lowercase all for avoiding case errors
            original_input.each{|key,value|
                input[key.downcase]=value
            }            

            @fields.each{|field|                
                value = input[field.name.downcase]
                                
                #check if it exists
                raise "Fatal: Required field '#{field.name}' not found when creating '#{self.type}'" if field.required and not value
                next if value == nil
                #check that it matches value_type (Ax, Nx)
                type_error = "Fatal: expected value for '#{field.type}' was of kind '#{ field.numeric? ? "Numeric" : "String" }', but a '#{value.class}' was privided"
                if field.numeric?  then  
                    autosize = (value.is_a? String and value.strip.downcase == "autosize" and field.autosizable)  
                    autocalculate = (value.is_a? String and value.strip.downcase == "autocalculate" and field.autocalculatable)
                    raise type_error if not value.is_a? Numeric unless (autosize or autocalculate)
                    next if autosize or autocalculate
                    range_error = "Fatal: '#{field.type}' value out of range (#{value}) in object '#{self.type}'... expected value between #{field.minimum} and #{field.maximum}"
                    raise range_error if (field.minimum and value < field.minimum) or (field.maximum and value > field.maximum)
                else                                       
                    raise type_error if not value.is_a? String
                end
            }
            return true
        end

        # Creates a new exact instance of the object. Was needed because
        # ruby handles some operations by reference, it seems.
        #
        # @author Germán Molina
        # @return [EnergyPlusObject] a copy of the object
        def clone
            ret = EnergyPlusObject.new(self.type)
            ret.fields = []
            @fields.each {|field|
                ret.fields << field.clone
            }
            ret.unique = self.unique
            ret.memo = self.memo
            ret.min_fields = self.min_fields
            ret.group = self.group
            ret.format = self.format
            ret.required = self.required
            ret.fields_as_indicated = self.fields_as_indicated
            ret.extensible = self.extensible
            return ret
        end

        # Gets the value of the given field. If the given field does not exist, 
        # it raises an error.
        #
        # The name of the field is compared case-insensitively
        #
        # @author Germán Molina
        # @param field_name [String] the name of the field to access
        # @return The value, if it exist
        def [](field_name)
            sel = @fields.select{|x| x.name.downcase == field_name.downcase}
            raise "Trying to access unkown field '#{field_name}' in object '#{self.type}'" if sel.length == 0
            return sel.shift.value
        end


        # Deletes the value in a certain field.
        #
        # @author Germán Molina
        # @param field_name [String] the name of the field to access
        # @return [Boolean] Success
        def delete(field_name)
            @fields.each{|f|
                next if not f.name.downcase.strip == field_name.downcase.strip
                f.set_value(nil) # this validates inputs, so it is better than just f.value=nil                
                return true
            }
            return false
        end
        
        # Sets the value for a certain field
        #
        # @author Germán Molina
        # @param field_name [String] the name of the field to access
        # @param value [String / Numeric] The value
        # @return [Boolean] Success
        def []=(field_name,value)
            @fields.each{|f|
                next if not f.name.downcase.strip == field_name.downcase.strip
                f.set_value(value) # this validates inputs                
                return true
            }
            return false
        end

        # Creates a copy of an objects and fills it with the provided inputs.
        # This is used because the values in the IDD object are stored empty, 
        # and from the scripts, we create copies of them and fill them.
        #
        # @author Germán Molina
        # @param original_input [Hash] The inputs for the new object
        # @return [EnergyPlusObject] The object
        def create(original_input)
            input = Hash.new
            #lowercase all for avoiding case errors
            original_input.each{|key,value|
                input[key.downcase]=value
            }       
            
            output = self.clone
            @fields.each{|field|                                                                          
                output[field.name] = input[field.name.downcase] if input.key? field.name.downcase                            
            }
            
            return output
        end        
                
        # Prints information about the object. It allows checking what fields are 
        # needed and which are not.
        #
        # @author Germán Molina
        def help
            puts "!- #{@name}"
            puts "!- #{@memo}"
            puts ""
            puts "#{@name},"
            @fields.each_with_index{|field,index|
                field.help(index == @fields.length - 1)
            }
            puts ""
            puts ""
        end

        # Checks how many fields are actually used and need to be prinetd in the object.
        # Since some objects allow a huge number of fields, but very often are all used 
        # (i.e. surfaces allow many vertices, but we usually use 3 or 4), this method
        # helps printing only those that are actually used, avoiding EnergyPlus errors
        # and reducing the size of the IDF file.
        #
        # If there is an unused field somewhere, but after that one there is a used field,
        # it will count the unused as used. That is, an array such as [1,nil,nil,2,nil] would
        # return 4, since the '2' needs to be printer as well.
        # 
        # @author Germán Molina
        # @return [Numeric] The number of used fields
        def n_used_fields
            length = @fields.length
            @fields.reverse.each_with_index{|field,index|                
                return length - index if (field.value.is_a? String or field.value.is_a? Numeric or field.required)
            }
            return @fields.length
        end

        # Prints the object, explicitly showing all the values of all fields.
        # That is, if there is no value, but a default is available, it will be 
        # printed.
        #
        # @author Germán Molina
        # @param file [File] An opened File object to print.
        def print(file)
            file.puts "#{@name.capitalize},"
            n = [self.n_used_fields, self.min_fields].max   
                     
            n.times{|index|
                field = @fields[index]               
                final = index == (n-1)
                field.print(file,final)
            }
        end

        # Returns the name of a certain object (i.e. Surfaces have unique names).
        # If the object does not have a name, it will return false.
        # @return [String / Boolean] The name, if it exists and False if it does not.
        def name
            name = @fields.select{|x| x.name.downcase == "name"}.shift               
            return name.value if name != nil
            return false                     
        end

        # Verifies that the type of an object matches the inputed one.
        # This is used for object-type specific methods.
        # This method is case unsensitive.
        # 
        # @author Germán Molina
        # @param type [String] The type to match.
        def verify(type)
            name.downcase == self.type.downcase            
        end

    end

end