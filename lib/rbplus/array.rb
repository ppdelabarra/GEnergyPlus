class Array
    def get_object_by_id(id)
        self.each{|object| 
            return object if object.id.downcase == id 
        }
        #warn "No object found on 'get_object_by_id' when looking for '#{id}'"
        return false
    end
end