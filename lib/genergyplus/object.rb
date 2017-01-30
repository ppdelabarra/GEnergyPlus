module EPlusModel     
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

            @fields.each{|field|                
                value = input[field.name.downcase]
                                
                #check if it exists
                raise "Fatal: Required field '#{field.name}' not found when creating '#{self.name}'" if field.required and not value
                next if value == nil
                #check that it matches value_type (Ax, Nx)
                type_error = "Fatal: expected value for '#{field.name}' was of kind '#{ field.numeric? ? "Numeric" : "String" }', but a '#{value.class}' was privided"
                if field.numeric?  then  
                    autosize = (value.is_a? String and value.strip.downcase == "autosize" and field.autosizable)  
                    autocalculate = (value.is_a? String and value.strip.downcase == "autocalculate" and field.autocalculatable)
                    raise type_error if not value.is_a? Numeric unless (autosize or autocalculate)
                    next if autosize or autocalculate
                    range_error = "Fatal: '#{field.name}' value out of range (#{value}) in object '#{self.name}'... expected value between #{field.minimum} and #{field.maximum}"
                    raise range_error if (field.minimum and value < field.minimum) or (field.maximum and value > field.maximum)
                else                                       
                    raise type_error if not value.is_a? String
                end
            }
            return true
        end

        def clone
            ret = EnergyPlusObject.new(self.name)
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

        def [](field_name)
            sel = @fields.select{|x| x.name.downcase == field_name.downcase}
            return false if sel.length == 0
            return sel.shift.value
        end

        def delete(field_name)
            @fields.each{|f|
                next if not f.name.downcase.strip == field_name.downcase.strip
                f.set_value(nil) # this validates inputs                
                return true
            }
            self.print
            return false
        end

        def []=(field_name,value)
            @fields.each{|f|
                next if not f.name.downcase.strip == field_name.downcase.strip
                f.set_value(value) # this validates inputs                
                return true
            }
            return false
        end

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

        def n_used_fields
            length = @fields.length
            @fields.reverse.each_with_index{|field,index|                
                return length - index if (field.value.is_a? String or field.value.is_a? Numeric or field.required)
            }
            return @fields.length
        end

        def print(file)
            file.puts "#{@name.capitalize},"
            n = [self.n_used_fields, self.min_fields].max   
                     
            n.times{|index|
                field = @fields[index]               
                final = index == (n-1)
                field.print(file,final)
            }
        end

        def id
            id = @fields.select{|x| x.name.downcase == "name"}.shift               
            return id.value if id != nil
            return false                     
        end

        def verify(name)
            name.downcase == self.name.downcase            
        end

    end

end