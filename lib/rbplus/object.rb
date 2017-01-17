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

        def []=(field_name,value)
            @fields.each{|f|
                next if not f.name.downcase.strip == field_name.downcase.strip
                f.value = value                
                return true
            }
            self.print
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

        def print
            puts "!- #{@name.capitalize}"
            puts "#{@name.capitalize},"
            @fields.each_with_index{|field,index|
                field.print(index == @fields.length - 1)
            }
        end

        def id
            id = @fields.select{|x| x.name.downcase == "name"}.shift               
            return id.value if id != nil
            return false                     
        end

        def verify(name)
            raise "Fatal:  '#{self.name}' is not a '#{name}'" if not name.downcase == self.name.downcase
            return true
        end

    end

end