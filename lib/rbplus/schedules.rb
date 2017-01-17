module EPlusModel      

    module Hours

        def self.standard_to_decimal(standard_time)
            hour = standard_time.split(":").shift.to_f
            minute = standard_time.split(":").pop.to_f
            raise "Imposible time inputed... '#{standard_time}'" if minute >= 60.0
            minute /= 60.0
            return hour + minute
        end

        def self.decimal_to_standard(decimal_time)
            hour = decimal_time.floor
            minute = decimal_time%1
            return "#{hour}:#{(minute * 60).to_i}"
        end

    end

    class Model

        def add_constant_schedule(name, value)
            inputs = { "name" => name, "Hourly value" => value }
            EPlusModel.model.add("Schedule:Constant",inputs)
        end

        def add_default_office_occupation_schedule(name,early,late, lunch)
            inputs = { "name" => name }
            inputs["Field 1"] = "Through: 12/31"
            inputs["Field 2"] = "Interpolate: Yes"
            inputs["Field 3"] = "For: Weekends Holidays"
            inputs["Field 4"] = "Until: 24:00, 0.0 "
                        
            inputs["Field 5"] = "For: AllOtherDays"
            early = EPlusModel::Hours.standard_to_decimal(early)
            late = EPlusModel::Hours.standard_to_decimal(late)
            lunch = EPlusModel::Hours.standard_to_decimal(lunch)

            #before arrival
            inputs["Field 6"] = "Until: #{EPlusModel::Hours.decimal_to_standard(early-0.5)} , 0.0"            
            inputs["Field 7"] = "Until: #{EPlusModel::Hours.decimal_to_standard(early+0.5)} , 1.0"

            #lunch
            inputs["Field 8"] = "Until: #{EPlusModel::Hours.decimal_to_standard(lunch-0.8)} , 1.0"            
            inputs["Field 9"] = "Until: #{EPlusModel::Hours.decimal_to_standard(lunch)} , 0.15"
            inputs["Field 10"] = "Until: #{EPlusModel::Hours.decimal_to_standard(lunch + 0.8)} , 1.0"


            #before leaving            
            inputs["Field 11"] = "Until: #{EPlusModel::Hours.decimal_to_standard(late-0.5)} , 1.0"            
            inputs["Field 12"] = "Until: #{EPlusModel::Hours.decimal_to_standard(late+0.5)} , 0.0"


            EPlusModel.model.add("Schedule:Compact",inputs)
        end

        def add_default_office_lighting_schedule(name,early,late)
            inputs = { "name" => name }
            inputs["Field 1"] = "Through: 12/31"
            inputs["Field 2"] = "Interpolate: Yes"
            inputs["Field 3"] = "For: Weekends Holidays"
            inputs["Field 4"] = "Until: 24:00, 0.0 "
                        
            inputs["Field 5"] = "For: AllOtherDays"
            early = EPlusModel::Hours.standard_to_decimal(early)
            late = EPlusModel::Hours.standard_to_decimal(late)
                        
            #before arrival
            inputs["Field 6"] = "Until: #{EPlusModel::Hours.decimal_to_standard(early-0.5)} , 0.0"            
            inputs["Field 7"] = "Until: #{EPlusModel::Hours.decimal_to_standard(early+0.5)} , 1.0"


            #before leaving            
            inputs["Field 8"] = "Until: #{EPlusModel::Hours.decimal_to_standard(late-0.5)} , 1.0"            
            inputs["Field 9"] = "Until: #{EPlusModel::Hours.decimal_to_standard(late+0.5)} , 0.0"


            EPlusModel.model.add("Schedule:Compact",inputs)
        end
    end
end