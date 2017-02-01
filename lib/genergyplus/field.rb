module EPlusModel  

    # This class represents the 'field'. A Field is a valid input to an object. For example, 
    # surfaces will have a material, a zone, etc. Each of these is a field.
    class EnergyPlusObjectField
        attr_accessor :name, :note, :required, :type, :value_type, :default, :keys, :value
        attr_accessor :minimum, :maximum, :retaincase, :units, :object_list, :reference, :ip_units
        attr_accessor :units_based_on_field, :autocalculatable, :autosizable, :external_list, :begin_extensible

        # Initializes an empty field.
        #
        # @author Germán Molina
        # @param name [String] The name of the field
        # @return [EnergyPlusObjectField] The field
        def initialize(name)
            @name = name
            @note = ""
            @required = false
            @type = false
            @value_type = false
            @default = false
            @keys = []
            @value = nil
            @minimum = false
            @maximum = false
            @retaincase = false
            @units = false
            @object_list = false
            @reference = false
            @ip_units = false
            @units_based_on_field = false
            @autocalculatable = false
            @autosizable = false
            @external_list = false
            @begin_extensible = false
        end

        # Prints a field by using the assigned value, if it exists, or the default value.
        # If neither of these exist, an error will raise.
        #
        # This method is usually called when printing an object.
        #
        # @author Germán Molina
        # @param file [File] File to print... it may be the STDOUT
        # @param final [Boolean] Represents whether this field is the last to be printed in an object or not. 
        def print(file,final)
            comma = ","
            comma = ";" if final
            if @value then
                file.puts "     #{@value}#{comma}     !-- #{@name}"
            else
                if @default then                    
                    file.puts "     #{@default}#{comma}     !-- #{@name} (default value)"                
                else
                    if @required then
                        raise "Fatal: not input nor default value at '#{@name}"
                    else                        
                        file.puts "     #{comma}     !-- #{@name} (value not required)"
                    end
                end
            end           
        end

        # Prints information about a field by showing if it is required, and what kind of
        # inputs it considers valid
        #
        # This method is usually called when printing an object.
        #
        # @author Germán Molina
        # @param file [File] File to print... it may be the STDOUT
        # @param final [Boolean] Represents whether this field is the last to be printed in an object or not. 
        def help (final)            
            comma = ","
            comma = ";" if final     
            default = "Default value: #{@default ?  @default : "FALSE" }"
            required = @required ? "REQUIRED" : "NOT REQUIRED" 
            choices = (@type.is_a? String and @type.downcase == "choice") ? "| Choices: [#{@keys.join(",")}]" : ""

            puts "     #{comma}     !-- #{@name}  ( Type: #{@type} | #{default} | #{required} #{choices} )"                                       
        end

        # Returns true if the if the field expects a numeric input
        # and false if it expects an alpha input.
        #
        # @author Germán Molina
        # @return [Boolean] is Numeric ?
        def numeric?
            @value_type[0].downcase == "n"
        end


        # Checks whether the value to assign is valid or not
        # 
        # @author Germán Molina
        # @param value [Numeric / String] The value to check 
        # @return [Boolean] is valid
        def check_input(value)
            # Check choices
            if @type.is_a? String and @type.downcase == "choice" then
                raise "Incorrect key in 'choice' field of... '#{value}' was inputed while the options are [#{@keys.join(",")}] " if not @keys.map{|x| x.downcase}.include? value.downcase
            end

            #check that it matches value_type (Ax, Nx)
            type_error = "Fatal: expected value for '#{self.name}' was of kind '#{ self.numeric? ? "Numeric" : "String" }', but a '#{value.class}' was provided"
            if self.numeric?  then                  
                # Autosize?
                autosize = (value.is_a? String and value.strip.downcase == "autosize" and self.autosizable)  
                # Autocalculate?
                autocalculate = (value.is_a? String and value.strip.downcase == "autocalculate" and self.autocalculatable)

                raise type_error if not value.is_a? Numeric unless (autosize or autocalculate)
                return true if autosize or autocalculate
                
                range_error = "Fatal: '#{self.type}' value out of range (#{value}) for '#{self.name}'... expected value between #{self.minimum} and #{self.maximum}"
                raise range_error if (self.minimum and value < self.minimum) or (self.maximum and value > self.maximum)
            else                                       
                raise type_error if not value.is_a? String
            end
            return true
        end   

        # Sets the value of the field. It checks if the value is correct.
        #
        # @author Germán Molina
        # @param value [Numeric / String] The value to assigned        
        def set_value(value)
            return if value == nil #not worth assigning it
            self.check_input(value) #this raises if there is an error
            self.value = value
        end

    end
end