module EPlusModel      
    class EnergyPlusObject


        def set_occupancy(calculation_method, value, npeople_schedule_name, activity_schedule_name, other_options)            
            raise "Fatal:  '#{self.name}' is not a '#{name}'" if not self.verify("zone") #this raises if needed
            id = "#{self.id} - people"
            
            if not EPlusModel.model.unique_id?("people",id) then
                EPlusModel.model.delete("people",id)                
            end     
            
            inputs = Hash.new

            inputs["name"] = id
            inputs["zone or zonelist name"] = self.id
            inputs["number of people calculation method"] = calculation_method
            inputs["number of people schedule name"] = npeople_schedule_name
            inputs["activity level schedule name"] = activity_schedule_name
            inputs.merge!(other_options)           

            case calculation_method.downcase
            when "people/area"
                inputs["people per zone floor area"] = value
            when "people"                
                inputs["number of people"] = value
            when "area/person"
                inputs["zone floor area per person"] = value
            else    
                raise "Incorrect calculation method '#{calculation_method}' when creating occupancy"
            end
            EPlusModel.model.add("people",inputs)
        end

        def set_lights(calculation_method, value, schedule_name, other_options)
            raise "Fatal:  '#{self.name}' is not a '#{name}'" if not self.verify("zone") #this raises if needed            
            id = "#{self.id} - lights"
            
            if not EPlusModel.model.unique_id?("people",id) then
                EPlusModel.model.delete("people",id)                
            end     

            inputs = Hash.new

            inputs["name"] = id
            inputs["zone or zonelist name"] = self.id            
            inputs["schedule name"] = schedule_name
            inputs["design level calculation method"]= calculation_method
            inputs.merge!(other_options)           

            case calculation_method.downcase
            when "lightinglevel"
                inputs["Lighting Level"] = value
            when "watts/area"                
                inputs["Watts per Zone Floor Area"] = value
            when "watts/person"
                inputs["Watts per person"] = value
            else    
                raise "Incorrect calculation method '#{calculation_method}' when creating lights"
            end
            EPlusModel.model.add("lights",inputs)            
        end



        

    end
end