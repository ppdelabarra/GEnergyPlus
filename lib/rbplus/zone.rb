module EPlusModel      
    class EnergyPlusObject


        def set_occupancy(calculation_method, value, npeople_schedule_name, activity_schedule_name)            
            self.verify("zone") #this raises if needed

            # Assumes the zone does not have this
            inputs = Hash.new

            inputs["name"] = "#{self.id} - people"
            inputs["zone or zonelist name"] = self.id
            inputs["number of people calculation method"] = calculation_method
            inputs["number of people schedule name"] = npeople_schedule_name
            inputs["activity level schedule name"] = activity_schedule_name

            EPlusModel.model.add("people",inputs)
        end

    end
end