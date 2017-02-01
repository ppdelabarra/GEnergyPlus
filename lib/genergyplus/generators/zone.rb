module EPlusModel      
    class EnergyPlusObject


        def adopt_other_options(object_name, other_options)
            inputs = other_options.clone if other_options
            inputs = Hash.new if not inputs

            name = "#{self.name} - #{object_name}"
            name = inputs["name"] if inputs.key? "name" 
            
            if not EPlusModel.model.unique_name?(object_name,name) then
                EPlusModel.model.delete(object_name,name)                
            end                 

            inputs["name"] = name 
            return inputs
        end

        def set_occupancy(calculation_method, value, npeople_schedule, activity_schedule, other_options)            
            raise "Fatal:  '#{self.name}' is not a Zone" if not self.verify("zone") #this raises if needed
            
            inputs = adopt_other_options("people",other_options)

            inputs["zone or zonelist name"] = self.name
            inputs["number of people calculation method"] = calculation_method
            inputs["number of people schedule name"] = npeople_schedule.name
            inputs["activity level schedule name"] = activity_schedule.name

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

        def set_lights(calculation_method, value, schedule, other_options)
            raise "Fatal:  '#{self.name}' is not a Zone" if not self.verify("zone") #this raises if needed     

            inputs = adopt_other_options("lights",other_options)

            inputs["zone or zonelist name"] = self.name           
            inputs["schedule name"] = schedule.name
            inputs["design level calculation method"] = calculation_method                   

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

        def set_electric_equipment(calculation_method, value, schedule, other_options)
            raise "Fatal:  '#{self.name}' is not a Zone" if not self.verify("zone") #this raises if needed     

            inputs = adopt_other_options("electricequipment",other_options)

            inputs["zone or zonelist name"] = self.name            
            inputs["schedule name"] = schedule.name
            inputs["design level calculation method"] = calculation_method                   

            case calculation_method.downcase
            when "equipmentlevel"
                inputs["Design Level"] = value
            when "watts/area"                
                inputs["Watts per Zone Floor Area"] = value
            when "watts/person"
                inputs["Watts per person"] = value
            else    
                raise "Incorrect calculation method '#{calculation_method}' when creating lights"
            end
            EPlusModel.model.add("electricequipment",inputs)            
        end

        def set_design_flow_rate_infiltration(calculation_method, value, schedule, other_options)
            raise "Fatal:  '#{self.name}' is not a Zone" if not self.verify("zone") #this raises if needed     

            inputs = adopt_other_options("ZoneInfiltration:DesignFlowRate",other_options)

            inputs["zone or zonelist name"] = self.name              
            inputs["schedule name"] = schedule.name
            inputs["design flow rate calculation method"] = calculation_method                   

            case calculation_method.downcase
            when "flow/zone"
                inputs["design flow rate"] = value
            when "flow/area"
                inputs["flow per zone floor area"] = value 
            when "flow/exteriorarea"
                inputs["flow per exterior surface area"] = value                
            when "flow/exteriorwallarea"
                inputs["flow per exterior surface area"] = value
            when "airchanges/hour"
                inputs["air changes per hour"] = value
            else
                raise "Incorrect calculation method '#{calculation_method}' for ZoneInfiltration:DesignFlowRate calculation"
            end
            EPlusModel.model.add("ZoneInfiltration:DesignFlowRate",inputs) 
        end

        def set_design_flow_rate_ventilation(calculation_method, value, schedule, other_options)
            raise "Fatal:  '#{self.name}' is not a Zone" if not self.verify("zone") #this raises if needed     

            inputs = adopt_other_options("ZoneVentilation:DesignFlowRate",other_options)

            inputs["zone or zonelist name"] = self.name              
            inputs["schedule name"] = schedule.name
            inputs["design flow rate calculation method"] = calculation_method                   

            case calculation_method.downcase
            when "flow/zone"
                inputs["design flow rate"] = value
            when "flow/area"
                inputs["flow rate per zone floor area"] = value 
            when "flow/person"
                inputs["Flow Rate per Person"] = value 
            when "airchanges/hour"
                inputs["air changes per hour"] = value
            else
                raise "Incorrect calculation method '#{calculation_method}' for ZoneInfiltration:DesignFlowRate calculation"
            end
            EPlusModel.model.add("ZoneVentilation:DesignFlowRate",inputs) 
        end

        def set_thermal_mass(construction,area, other_options)
            raise "Fatal:  '#{self.type}' is not a Zone" if not self.verify("zone") #this raises if needed     

            inputs = adopt_other_options("InternalMass",other_options)
            inputs["zone name"] = self.name       
            inputs["Surface Area"] = area
            raise "Fatal: '#{construction.name}' is not a Construction... it is a '#{construction.type}'" if not construction.verify("construction")
            inputs["Construction Name"] = construction.name
            EPlusModel.model.add("InternalMass",inputs)
        end


        

    end
end