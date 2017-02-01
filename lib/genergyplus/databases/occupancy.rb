module EPlusModel      

    # This module contains information about the metabolic rate of some
    # common human activities. This module allows retrieveing data in an easier way, 
    # and allowing an easier to read code.
    #
    # Data presented here is useful for ensuring more precise building models.
    # 
    module People
       @@data = Hash.new

       
        # Source: EnergyPlus 8.6 Input Output reference
       @@data["Sleeping"] = 72
       @@data["Reclining"] = 81
       @@data["Seated, quiet"] = 108
       @@data["Standing, relaxed"] = 126

       ### WALKING
       @@data["Walking slow"] = 207
       @@data["Walking normal"] = 270
       @@data["Walking fast"] = 396

       ### OFFICE
       @@data["Reading seated"] = 99
       @@data["Writing"] = 108
       @@data["Typing"] = 117
       @@data["Filing, seated"] = 126
       @@data["Filing, standing"] = 144
       @@data["Walking about"] = 180
       @@data["Lifting / Packing"] = 216

       ### MISCELANEOUS OCCUPATIONAL ACTIVITIES
       @@data["Cooking"] = (171 + 207)/2       
       @@data["Housecleaning"] = (207 + 360)/2
       @@data["Seated, heavy limb movement"] = 234
       @@data["Machine work"] = 189
       @@data["Sawing"] = (207 + 252)/2       
       @@data["Light (electrical industry)"] = 423
       @@data["Handling 50kg bags"] = 423
       @@data["Pick and shovel work"] = (423 + 504)/2
       
       ### MISCELANEOUS LEISURE ACTIVITIES
       @@data["Dancing"] = (252 + 459)/2
       @@data["Excercise"] = (315 + 423)/2       
       @@data["Tennis, singles"] = (378 + 486)/2       
       @@data["Basketball, competitive"] = (522 + 792)/2
       @@data["Wrestling, competitive"] = (738 + 909)/2
       
        # Retrieves the metabolic rate of certain activity.
        #
        # @author Germán Molina
        # @param description [String] The activity
        # @return [Numeric] The data
        def self.heat_gain_per_person(description)            
            @@data.each{|key,value|
                return value if key.downcase.strip == description.downcase.strip
            }
            return false
        end 

    
    end
end