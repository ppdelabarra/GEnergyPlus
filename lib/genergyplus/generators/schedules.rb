module EPlusModel      

    # This module helps handling times and dates.
    module Hours

        # Transform a standard time (i.e. '10:30') into decimal time
        # (i.e. '10,5')
        #
        # @author Germán Molina
        # @param standard_time [String] The time
        # @return [Numeric] The time in decimal
        def self.standard_to_decimal(standard_time)
            hour = standard_time.split(":").shift.to_f
            minute = standard_time.split(":").pop.to_f
            raise "Imposible time inputed... '#{standard_time}'" if minute >= 60.0
            minute /= 60.0
            return hour + minute
        end

        # Transform a decimal time (i.e. '10,5') into standard time
        # (i.e. '10:30')
        #
        # @author Germán Molina
        # @param decimal_time [Numeric] The time
        # @return [String] The time in standard
        def self.decimal_to_standard(decimal_time)
            hour = decimal_time.floor
            minute = decimal_time%1
            return "#{hour}:#{format('%02d',(minute * 60).to_i)}"
        end

    end

    class Model

        
        # Creates a schedule that has a specific value for each
        # hour of working day. Weekends and holidays are 0.
        #
        # @param name [String] the name of the schedule
        # @param values [Array] An array with 24 values, one for each hour
        def add_hourly_schedule_with_empty_weekends(name,values)
            raise "Value for 24 hours of the day are required" if values.length != 24
            inputs = {"name" => name}
            inputs["Field 1"] = "Through: 12/31"
            inputs["Field 2"] = "For: Weekends Holidays"
            inputs["Field 3"] = "Interpolate: Yes"
            inputs["Field 4"] = "Until: 24:00, 0.0"

            inputs["Field 5"] = "For: AllOtherDays"
            inputs["Field 6"] = "Interpolate: Yes"

            values.each_with_index{|value,hour|
                inputs["Field #{7+hour}"] = "Until: #{EPlusModel::Hours.decimal_to_standard(hour+1)} , #{value}"
            }
            self.add("Schedule:Compact",inputs)
        end

        # Adds a Schedule:Constant object to the model, with the
        # inputed value.
        #
        # @author Germán Molina
        # @param name [String] The name of the Schedule
        # @param value [Numeric] The value of the schedule
        # @return [EnergyPlusObject] The new schedule
        def add_constant_schedule(name, value)
            inputs = { "name" => name, "Hourly value" => value }
            EPlusModel.model.add("Schedule:Constant",inputs)
        end

        # Adds a Schedule:Compact object to the model, which represents a 
        # sensible occupancy schedule for offices. That is, it is 0 (zero)
        # outside working hours, and 1 during working hours.
        #
        # People start arriving half an hour earlier to the 
        # start of working hours, and it is completely full an hour later.
        # Likewise, people start leaving half hour earlier to the end of the
        # working hours, and the office is completely empty an hour after that.
        #
        # Lunch period lasts 1.5 hours, but not everyone has lunch at the same time.
        # The first ones leave 45 minutes before the provided lunch time, and the 
        # last come back 45 minutes after the provided lunch. The given lunch time
        # represents the time with least occupancy, which is 15% of the total.
        #
        # It is zero during weekends and Holidays
        #
        # @author Germán Molina
        # @param name [String] The name of the Schedule
        # @param early [String] The start of the working hours (i.e. '9:00')
        # @param late [String] The end of the working hours (i.e. '19:00')
        # @param lunch [String] Lunch time (i.e. '13:30')
        # @return [EnergyPlusObject] The new schedule
        def add_default_office_occupation_schedule(name,early,late, lunch)
            inputs = { "name" => name }
            inputs["Field 1"] = "Through: 12/31"            
            inputs["Field 2"] = "For: Weekends Holidays"
            
            inputs["Field 3"] = "Interpolate: Yes"
            inputs["Field 4"] = "Until: 24:00, 0.0 "
                        
            inputs["Field 5"] = "For: AllOtherDays"
            early = EPlusModel::Hours.standard_to_decimal(early)
            late = EPlusModel::Hours.standard_to_decimal(late)
            lunch = EPlusModel::Hours.standard_to_decimal(lunch)

            #before arrival
            
            inputs["Field 6"] = "Interpolate: Yes"
            inputs["Field 7"] = "Until: #{EPlusModel::Hours.decimal_to_standard(early-0.5)} , 0.0"            
            inputs["Field 8"] = "Until: #{EPlusModel::Hours.decimal_to_standard(early+0.5)} , 1.0"

            #lunch
            inputs["Field 9"] = "Until: #{EPlusModel::Hours.decimal_to_standard(lunch-0.75)} , 1.0"            
            inputs["Field 10"] = "Until: #{EPlusModel::Hours.decimal_to_standard(lunch)} , 0.15"
            inputs["Field 11"] = "Until: #{EPlusModel::Hours.decimal_to_standard(lunch + 0.75)} , 1.0"


            #before leaving            
            inputs["Field 12"] = "Until: #{EPlusModel::Hours.decimal_to_standard(late-0.5)} , 1.0"            
            inputs["Field 13"] = "Until: #{EPlusModel::Hours.decimal_to_standard(late+0.5)} , 0.0"


            EPlusModel.model.add("Schedule:Compact",inputs)
        end

        # Adds a Schedule:Compact object to the model, which represents a 
        # sensible lighting use schedule for offices. That is, it is 0 (zero)
        # outside working hours, and 1 during working hours.
        #
        # It is the same as the occupancy schedule, but without lunch.
        #
        # @author Germán Molina
        # @param name [String] The name of the Schedule
        # @param early [String] The start of the working hours (i.e. '9:00')
        # @param late [String] The end of the working hours (i.e. '19:00')
        # @return [EnergyPlusObject] The new schedule
        def add_default_office_lighting_schedule(name,early,late)
            inputs = { "name" => name }                        
            inputs["Field 1"] = "Through: 12/31"
            inputs["Field 2"] = "For: Weekends Holidays"
            inputs["Field 3"] = "Interpolate: Yes"
            inputs["Field 4"] = "Until: 24:00, 0.0 "
                        
            inputs["Field 5"] = "For: AllOtherDays"
            inputs["Field 6"] = "Interpolate: Yes"
            early = EPlusModel::Hours.standard_to_decimal(early)
            late = EPlusModel::Hours.standard_to_decimal(late)
                        
            #before arrival
            inputs["Field 7"] = "Until: #{EPlusModel::Hours.decimal_to_standard(early-0.5)} , 0.0"            
            inputs["Field 8"] = "Until: #{EPlusModel::Hours.decimal_to_standard(early+0.5)} , 1.0"


            #before leaving            
            inputs["Field 9"] = "Until: #{EPlusModel::Hours.decimal_to_standard(late-0.5)} , 1.0"            
            inputs["Field 10"] = "Until: #{EPlusModel::Hours.decimal_to_standard(late+0.5)} , 0.0"


            EPlusModel.model.add("Schedule:Compact",inputs)
        end

        def add_default_HVAC_schedule(name,early,late)
            inputs = { "name" => name }                        
            inputs["Field 1"] = "Through: 12/31"
            inputs["Field 2"] = "For: Weekends Holidays"
            inputs["Field 3"] = "Interpolate: Yes"
            inputs["Field 4"] = "Until: 24:00, 0.0 "
                        
            inputs["Field 5"] = "For: AllOtherDays"
            inputs["Field 6"] = "Interpolate: No"
            early = EPlusModel::Hours.standard_to_decimal(early)
            late = EPlusModel::Hours.standard_to_decimal(late)
                        
            #before arrival
            inputs["Field 7"] = "Until: #{EPlusModel::Hours.decimal_to_standard(early)} , 0.0"            

            #before leaving            
            inputs["Field 8"] = "Until: #{EPlusModel::Hours.decimal_to_standard(late)} , 1.0"            
            inputs["Field 9"] = "Until: 24:00 , 0.0"


            EPlusModel.model.add("Schedule:Compact",inputs)
        end


        # Adds a schedule that is a certain value during working days and
        # another during weekends and Holidays.
        #
        # This is useful for assigning thermostats, for example.
        #
        # @author Germán Molina
        # @param name [String] The name of the schedule
        # @param office_day_value [Numeric] The working hour value
        # @param holiday_value [Numeric] The value during Holidays and weekends
        def add_office_day_schedule(name, office_day_value, holiday_value)
            inputs = { "name" => name }                        
            inputs["Field 1"] = "Through: 12/31"
            inputs["Field 2"] = "For: Weekends Holidays"
            inputs["Field 3"] = "Interpolate: Yes"
            inputs["Field 4"] = "Until: 24:00, #{holiday_value}"
                        
            inputs["Field 5"] = "For: AllOtherDays"
            inputs["Field 6"] = "Interpolate: Yes"
            inputs["Field 7"] = "Until: 24:00, #{office_day_value}"            

            EPlusModel.model.add("Schedule:Compact",inputs)
        end
    end
end