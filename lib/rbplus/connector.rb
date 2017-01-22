
module EPlusModel

    class EnergyPlusObject
        def add_outlet(branch)
            raise "Fatal:  '#{self.name}' is not a Connector:Splitter" if not self.verify("Connector:Splitter") #this raises if needed     
            self.fields.each_with_index{|field,index|
                next if field.value
                field.value = branch.id
                return self
            }
            warn "Outlet not added"
        end

        def add_inlet(branch)
            raise "Fatal:  '#{self.name}' is not a Connector:Mixer" if not self.verify("Connector:Mixer") #this raises if needed     
            self.fields.each_with_index{|field,index|            
                next if field.value
                field.value = branch.id
                return self
            }
            warn "Inlet Not Added"
        end

        
    end
end
