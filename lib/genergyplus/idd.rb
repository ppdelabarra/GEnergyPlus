
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
                        @data[object_name].fields[-1].begin_extensible = true
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
                        @data[object_name].memo += " #{content.strip}"
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

        def get_required_objects_list
            required_objects = []
            @data.each{|key,object|                
                required_objects << object.name if object.required
            }
            return required_objects        
        end

        def [](object_name)
            object_name.strip!
            raise "Trying to add inexistent object '#{object_name}'" if not @data.key? object_name.downcase         
            @data[object_name.downcase]
        end

        def keys
            @data.keys
        end


    end  

   
end
