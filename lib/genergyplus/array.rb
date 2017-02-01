#Extension to the core Array class
class Array
    
    # Allows finding an object by name within an array of EnergyPlusObject
    #
    # @author Germán Molina
    # @param name [String] The name of the object to find.
    # @return [EnergyPlusObject] The object, if found. False if not.
    def get_object_by_name(name)
        self.each{|object| 
            return object if object.name.downcase == name.downcase
        }
        return false
    end    
end
