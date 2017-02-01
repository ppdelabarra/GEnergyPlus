module EPlusModel

    # This module contains information about some luminaires and lamps.
    # This information is non-intuitive and is not really easy to find.
    # Also, default values are not necessarily correct.
    #
    # Data presented here is useful for ensuring more precise building models.
    #
    module Lights
        
        @@data = Hash.new

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Recessed, Parabolic Louver, Non-vented, T8"] =  { #1
                        "Return Air Fraction" => 0.31,
                        "Fraction Radiant" => 0.22,
                        "Fraction visible" => 0.2
                    }
        
        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Recessed, Acrylic Lens, Non-vented, T8"] =  { #2
                        "Return Air Fraction" => 0.56,
                        "Fraction Radiant" => 0.12,
                        "Fraction visible" => 0.2
                    }                    

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Recessed, Parabolic Louver,Vented, T8"] =  { #3
                        "Return Air Fraction" => 0.28,
                        "Fraction Radiant" => 0.19,
                        "Fraction visible" => 0.2
                    }                           

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Recessed, Acrylic Lens, vented, T8"] =  { #4
                        "Return Air Fraction" => 0.54,
                        "Fraction Radiant" => 0.1,
                        "Fraction visible" => 0.18
                    }                           

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Recessed, Direct/Indirect, T8"] =  { #5
                        "Return Air Fraction" => 0.34,
                        "Fraction Radiant" => 0.17,
                        "Fraction visible" => 0.16
                    }                           

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Recessed, Volumetric, T5"] =  { #6
                        "Return Air Fraction" => 0.54,
                        "Fraction Radiant" => 0.13,
                        "Fraction visible" => 0.2
                    }                            

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Downlights, Compact Fluorescent, DTT"] =  { #7
                        "Return Air Fraction" => 0.86,
                        "Fraction Radiant" => 0.04,
                        "Fraction visible" => 0.10
                    }                            

        # Source: EnergyPlus 8.6 Input Output reference  
        @@data["Downlights, Compact Fluorescent, TRT"] =  { #8
                        "Return Air Fraction" => 0.78,
                        "Fraction Radiant" => 0.09,
                        "Fraction visible" => 0.13
                    }                             

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Downlights, Incandescent, A21"] =  { #9a
                        "Return Air Fraction" => 0.29,
                        "Fraction Radiant" => 0.1,
                        "Fraction visible" => 0.6
                    }                                                   

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Downlights, Incandescent, BR40"] =  { #9b
                        "Return Air Fraction" => 0.21,
                        "Fraction Radiant" => 0.08,
                        "Fraction visible" => 0.71
                    }                              

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Surface Mounted, T5H0"] =  { #10
                        "Return Air Fraction" => 0.0,
                        "Fraction Radiant" => 0.27,
                        "Fraction visible" => 0.23
                    }                              

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Pendant, Direct/Indirect, T8"] =  { #11
                        "Return Air Fraction" => 0.0,
                        "Fraction Radiant" => 0.32,
                        "Fraction visible" => 0.23
                    }                           

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Pendant, Indirect, T5H0"] =  { #12
                        "Return Air Fraction" => 0.0,
                        "Fraction Radiant" => 0.32,
                        "Fraction visible" => 0.25
                    }   

                    ########################

        @@data["Recessed, Parabolic Louver, Non-vented, T8 - ducted"] =  { #1
                        "Return Air Fraction" => 0.27,
                        "Fraction Radiant" => 0.27,
                        "Fraction visible" => 0.21
                    }                             

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Recessed, Direct/Indirect, T8 - Ducted"] =  { #5
                        "Return Air Fraction" => 0.27,
                        "Fraction Radiant" => 0.22,
                        "Fraction visible" => 0.17
                    }   

                    ########################                           

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Recessed, Parabolic Louver, Non-vented, T8 - Half Typical"] =  { #1
                        "Return Air Fraction" => 0.45,
                        "Fraction Radiant" => 0.3,
                        "Fraction visible" => 0.22
                    }                             

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Recessed, Parabolic Louver, Vented, T8 - Half Typical Supply Airflow Rate"] =  { #3
                        "Return Air Fraction" => 0.43,
                        "Fraction Radiant" => 0.25,
                        "Fraction visible" => 0.21
                    }                              

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Recessed, Direct/Indirect, T8 - Half Typical Supply Airflow Rate"] =  { #5
                        "Return Air Fraction" => 0.43,
                        "Fraction Radiant" => 0.25,
                        "Fraction visible" => 0.21
                    }   

                    ########################                           

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Recessed, Parabolic Louver, Non-Vented, T8 - Half Typical Supply Airflow Rate"] =  { #1
                        "Return Air Fraction" => 0.1,
                        "Fraction Radiant" => 0.16,
                        "Fraction visible" => 0.11
                    }                              

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Recessed, Parabolic Louver, Vented, T8 - Half Typical Supply Airflow Rate"] =  { #3
                        "Return Air Fraction" => 0.11,
                        "Fraction Radiant" => 0.15,
                        "Fraction visible" => 0.19
                    }                              

        # Source: EnergyPlus 8.6 Input Output reference
        @@data["Recessed, Direct/Indirect, T8 - Half Typical Supply Airflow Rate"] =  { #3
                        "Return Air Fraction" => 0.04,
                        "Fraction Radiant" => 0.13,
                        "Fraction visible" => 0.16
                    }                              
        
        
        # Retrieves data for a certain type of lamp.
        #
        # @author Germán Molina
        # @param description [String] The name of the lamp
        # @return [Hash] The data
        def self.lamp_data(description)            
            @@data.each{|key,value|
                return value if key.downcase.strip == description.downcase.strip
            }
            return false
        end 


    end
end