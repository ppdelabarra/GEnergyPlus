module EPlusModel      

    # This module contains parameters related to infiltration. For example,
    # the constants used by BLAST and DOE-2 for calculating infiltration in the
    # Infiltration:DesignFlowRate object.    
    #
    module Infiltration
        @@data = Hash.new

        @@data["DesignFlowRate:BLAST"] = { 
            "Constant Term Coefficient" => 0.606,
            "Temperature Term Coefficient" => 0.03636,
            "Velocity Term Coefficient" => 0.1177,
            "Velocity Squared Term Coefficient" => 0.0
         }

        
        @@data["DesignFlowRate:DOE-2"] = { 
            "Constant Term Coefficient" => 0.0,
            "Temperature Term Coefficient" => 0.0,
            "Velocity Term Coefficient" => 0.224,
            "Velocity Squared Term Coefficient" => 0.0
         } 

        # Retrieves some infiltration data.
        #
        # @author Germán Molina
        # @param description [String] The name of the data to retrieve
        # @return [Hash] The data
        def self.get_coefficients(description)            
            @@data.each{|key,value|
                return value if key.downcase.strip == description.downcase.strip
            }
            return false
        end 
    end
end