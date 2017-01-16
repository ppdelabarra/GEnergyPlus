module EPlusModel  
    class IDD
       
        def initialize(file)
            @data = Hash.new
            lines = File.readlines(file).select{|ln| not ln.start_with? "!" and not ln.strip == ""}
            
            group = false
            object_name = false
            while lines.length > 0 do
                ln = lines.shift.strip
                next if ln == "Lead Input;"
                next if ln == "Simulation Data;"
                
                #update group, if needed
                if ln.include? "\\group" then
                    group = ln.gsub("\\group","").strip 
                    next
                end

                # Starts a new object
                if not ln.include? "\\" then
                    object_name = ln.strip.downcase.gsub(",","").gsub(";","")                    
                    @data[object_name] = EnergyPlusObject.new(object_name)
                    @data[object_name].group = group  
                    next                  
                end

                #process other lines
                if ln.include? "\\field" #A field is starting                    
                    d = ln.split("\\field")
                    value_type = d[0].gsub(";","").strip
                    field_name = d[1].strip
                    @data[object_name].fields << EnergyPlusObjectField.new(field_name)
                    @data[object_name].fields[-1].value_type = value_type
                    next
                elsif ln.include? "\\note fields as indicated" or ln.include? "\\note For Week"
                    @data[object_name].fields_as_indicated = true
                    next
                elsif ln.include? "\\extensible:"
                    d = ln.split(" ").shift.split(":")                    
                    @data[object_name].extensible = d.pop.to_i
                    next
                else
                    d = ln.split(" ")                    
                    flag = d.shift.strip.downcase                    
                    content = d.join(" ").strip
                    case flag
                    # These are field flags
                    when "\\note"
                        @data[object_name].fields[-1].note += content
                        next
                    when "\\type"
                        @data[object_name].fields[-1].type = content
                        next
                    when "\\default"
                        @data[object_name].fields[-1].default = content
                        next
                    when "\\key"
                        @data[object_name].fields[-1].keys << content
                        next
                    when "\\minimum"
                        @data[object_name].fields[-1].minimum = content.to_f
                        next
                    when "\\minimum>"
                        @data[object_name].fields[-1].minimum = content.to_f+1e-6
                        next 
                    when "\\maximum"
                        @data[object_name].fields[-1].maximum = content.to_f
                        next
                    when "\\maximum<"
                        @data[object_name].fields[-1].maximum = content.to_f-1e-6
                        next  
                    when "\\retaincase"
                        @data[object_name].fields[-1].retaincase = true
                        next   
                    when "\\units"
                        @data[object_name].fields[-1].units = content
                        next   
                    when "\\object-list"
                        @data[object_name].fields[-1].object_list = content
                        next   
                    when "\\required-field"
                        @data[object_name].fields[-1].required = true
                        next    
                    when "\\reference"
                        @data[object_name].fields[-1].reference = content
                        next     
                    when "\\ip-units"
                        @data[object_name].fields[-1].ip_units = content
                        next         
                    when "\\unitsbasedonfield"
                        @data[object_name].fields[-1].units_based_on_field = content
                        next                             
                    when "\\begin-extensible"
                        #@data[object_name].fields[-1].units_based_on_field = content
                        next                             
                    when "\\autocalculatable"
                        @data[object_name].fields[-1].autocalculatable = true
                        next                             
                    when "\\autosizable"
                        @data[object_name].fields[-1].autosizable = true
                        next                             
                    when "\\external-list"
                        @data[object_name].fields[-1].external_list = content
                        next                                                 

                    # These are object flags
                    when "\\memo"
                        @data[object_name].memo += content
                        next
                    when "\\unique-object"
                        @data[object_name].unique = true
                        next   
                    when "\\format"
                        @data[object_name].format = content
                        next   
                    when "\\required-object"
                        @data[object_name].required = true
                        next   
                    when "\\min-fields"
                        @data[object_name].min_fields = content.to_i
                        next   
                    else
                        warn ln
                        raise "Fatal: Unknown flag '#{flag.gsub("\\","")}' when reading '#{file}' IDD file"
                    end
                end
            end                 
        end                

        def [](object_name)
            raise "Trying to add inexistent object '#{object_name}'" if not @data.key? object_name         
            @data[object_name]
        end
    end  

    class EnergyPlusObject
        attr_accessor :name, :fields, :unique, :memo, :min_fields, :group 
        attr_accessor :format, :required, :fields_as_indicated, :extensible

        def initialize(name)
            @name=name
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

        def check_input(original_input)
            input = Hash.new
            #lowercase all for avoiding case errors
            original_input.each{|key,value|
                input[key.downcase]=value
            }            
#            return false if not input["name"] and input["name"].is_a? String

            @fields.each{|field|                
                value = input[field.name.downcase]
                                
                #check if it exists
                raise "Fatal: Required field '#{field.name}' not found when creating '#{self.name}'" if field.required and not value
                next if value == nil
                #check that it matches value_type (Ax, Nx)
                type_error = "Fatal: expected value for '#{field.name}' was of kind '#{ field.value_type[0].downcase == "n" ? "Numeric" : "String" }', but a '#{value.class}' was privided"
                if field.value_type[0].downcase == "n"  then
                    raise type_error if not value.is_a? Numeric
                    range_error = "Fatal: '#{field.name}' value out of range in object '#{self.name}'... expected value between #{field.minimum} and #{field.maximum}"
                    raise range_error if (field.minimum and value < field.minimum) or (field.maximum and value > field.maximum)
                elsif field.value_type[0].downcase == "a"  then                                        
                    raise type_error if not value.is_a? String
                else
                    warn "WARNING: Invalid value_type '#{field.value_type}' at '#{self.name}'"
                end
            }
            return true
        end

        def create(original_input)
            input = Hash.new
            #lowercase all for avoiding case errors
            original_input.each{|key,value|
                input[key.downcase]=value
            }       
            @fields.each{|field|
                value = input[field.name.downcase]                  
                field.value = value if value
            }
            return self
        end

        def print
            puts "!- #{@name}"
            puts "#{@name},"
            @fields.each_with_index{|field,index|
                field.print(index == @fields.length - 1)
            }
        end

    end

    class EnergyPlusObjectField
        attr_accessor :name, :note, :required, :type, :value_type, :default, :keys, :value
        attr_accessor :minimum, :maximum, :retaincase, :units, :object_list, :reference, :ip_units
        attr_accessor :units_based_on_field, :autocalculatable, :autosizable, :external_list

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
        end

        def print(final)
            comma = ","
            comma = ";" if final
            if @value then
                puts "     #{@value.to_s}#{comma}     !-- #{@name}"
            else
                if @default then
                    puts "     #{@default.to_s}#{comma}     !-- #{@name} (default value)"                
                else
                    if @required then
                        raise "Fatal: not input nor default value at '#{@name}"
                    else
                        puts "     #{comma}     !-- #{@name} (value not required)"
                    end
                end
            end
        end
    end
end
