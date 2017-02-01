class Array
    def get_object_by_name(name)
        self.each{|object| 
            return object if object.name.downcase == name.downcase
        }
        return false
    end    
end
