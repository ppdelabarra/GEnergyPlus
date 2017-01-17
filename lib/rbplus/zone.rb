module EPlusModel      
    class EnergyPlusObject


        def set_occupancy(calculation_method, value, npeople_schedule_name, activity_schedule_name)            
            raise "Fatal:  '#{self.name}' is not a '#{name}'" if not self.verify("zone") #this raises if needed
            id = "#{self.id} - people"
            
            if not EPlusModel.model.verify_unique_id("people",id) then
                EPlusModel.model.delete("people",id)                
            end     
            

            # Assumes the zone does not have this
            inputs = Hash.new

            inputs["name"] = id
            inputs["zone or zonelist name"] = self.id
            inputs["number of people calculation method"] = calculation_method
            inputs["number of people schedule name"] = npeople_schedule_name
            inputs["activity level schedule name"] = activity_schedule_name

            case calculation_method.downcase
            when "people/area"
                inputs["people per zone floor area"] = value
            when "people"                
                inputs["number of people"] = value
            when "area/person"
                inputs["zone floor area per person"] = value
            else    
                raise "Incorrect calculation method when creating occupancy"
            end


            EPlusModel.model.add("people",inputs)
        end

        

    end
end