module EPlusModel      
    class EnergyPlusObject

        # This method helps managing the "other options" passsed to some generators.
        # For example, the "set_occupancy" method helps easily adding occupancy to 
        # a zone by means of a 'people' obejct. However, you might want, sometimes, 
        # to include some specific options (i.e. a specific name or maybe a precise 
        # value for latent and sensible heat generation)
        #
        # This method, by default, creates the "input" hash for creating the "poeple"
        # (in the example above) object, by including all the options added in the 
        # "other_options" hash, adding a name if not given one, and deleting the alrady
        # existing object with the same name if it already exists
        #
        # @author Germán Molina
        # @param object_type [String] The type of the object to which this is focused
        # @param other_options [Hash] The other options hash
        # @return [Hash] The inputs for creating the object
        def adopt_other_options(object_type, other_options)
            inputs = other_options.clone if other_options
            inputs = Hash.new if not inputs

            name = "#{self.name} - #{object_type}"
            name = inputs["name"] if inputs.key? "name" 
            
            if not EPlusModel.model.unique_name?(object_type,name) then
                EPlusModel.model.delete(object_type,name)                
            end                 

            inputs["name"] = name 
            return inputs
        end

        # Sets the occupancy of the zone to a certain value, schedule and activity
        # by creating a 'people' object.
        #
        # Aditional options may be given to the 'people' object in the 'other_options' hash
        #
        # @author Germán Molina
        # @param calculation_method [String] The calculation method to use (i.e. people/area, people, area/person)
        # @param value [Numeric] The value to assign, in the units selected in the calculation method
        # @param npeople_schedule [EnergyPlusObject] The schedule that modulates the number of people
        # @param activity_schedule [EnergyPlusObject] The schedule that represents the activity (i.e. metabolic rate) of the people
        # @param other_options [Hash] Some other options that may be provided to the 'people' object.
        # @return [EnergyPlusObject] the created object
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

        # Sets the lighting loads of the zone to a certain value and schedule
        # by creating a 'lights' object.
        #
        # Aditional options may be given to the 'lights' object in the 'other_options' hash
        #
        # @author Germán Molina
        # @param calculation_method [String] The calculation method to use (i.e. LightingLevel, Watts/area, Watts/Person)
        # @param value [Numeric] The value to assign, in the units selected in the calculation method
        # @param schedule [EnergyPlusObject] The schedule that modulates the loads
        # @param other_options [Hash] Some other options that may be provided to the 'light' object.
        # @return [EnergyPlusObject] the created object
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

        # Sets the Electric Equipment loads of the zone to a certain value and schedule
        # by creating an 'ElectricEquipment' object.
        #
        # Aditional options may be given to the created object in the 'other_options' hash
        #
        # @author Germán Molina
        # @param calculation_method [String] The calculation method to use (i.e. EquipmentLevel, Watts/area, Watts/Person)
        # @param value [Numeric] The value to assign, in the units selected in the calculation method
        # @param schedule [EnergyPlusObject] The schedule that modulates the loads
        # @param other_options [Hash] Some other options that may be provided to the object.
        # @return [EnergyPlusObject] the created object
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

        # Sets the infiltration rate by creating a 'ZoneInfiltration:DesignFlowRate' object
        #
        # Aditional options may be given to the created object in the 'other_options' hash. this
        # is particularly useful for adding the constant coefficients for calculating the infiltration. 
        #
        # @author Germán Molina
        # @param calculation_method [String] The calculation method to use (i.e. flow/zone, flow/area, flow/exteriorArea, flow/ExteriorWallArea, AirChanges/hour)
        # @param value [Numeric] The value to assign, in the units selected in the calculation method
        # @param schedule [EnergyPlusObject] The schedule that modulates the infiltrations
        # @param other_options [Hash] Some other options that may be provided to the object.
        # @return [EnergyPlusObject] the created object
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

        # Sets the ventilation rate by creating a 'ZoneVentilation:DesignFlowRate' object
        #
        # Aditional options may be given to the created object in the 'other_options' hash
        #
        # @author Germán Molina
        # @param calculation_method [String] The calculation method to use (i.e. flow/zone, flow/area, flow/exteriorArea, flow/ExteriorWallArea, AirChanges/hour)
        # @param value [Numeric] The value to assign, in the units selected in the calculation method
        # @param schedule [EnergyPlusObject] The schedule that modulates the infiltrations
        # @param other_options [Hash] Some other options that may be provided to the object.
        # @return [EnergyPlusObject] the created object
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

        # Adds thermal mass to a zone by creating an 'InternalMass' object.
        #
        # Aditional options may be given to the created object in the 'other_options' hash
        #
        # @author Germán Molina
        # @param construction [EnergyPlusObject] The construction to use
        # @param area [Numeric] The surface area (in m2) of construction to add to the zone
        # @param other_options [Hash] Some other options that may be provided to the object.
        # @return [EnergyPlusObject] the created object
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