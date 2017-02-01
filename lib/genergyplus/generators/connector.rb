
module EPlusModel

    class Model
        
        def add_branch_list(name,branch_array)
            inputs = { "name" => name }
            branch_array.each_with_index{|branch,index|
                inputs["Branch #{index+1} Name"]=branch.name
            }
            self.add("branchlist",inputs)
        end

        def add_connector_list(name,connector_array)
            inputs = { "name" => name }
            connector_array.each_with_index{|connector,index|
                inputs["Connector #{index + 1} Object Type"]=connector.name
                inputs["Connector #{index + 1} name"]=connector.name
            }
            self.add("ConnectorList",inputs)
        end

        def add_splitter(name,inlet_branch,outlet_branch_array)
            inputs = { "name" => name }
            inputs["Inlet branch name"] = inlet_branch.name
            outlet_branch_array.each_with_index{|branch,index|
                inputs["Outlet Branch #{index+1} Name"] = branch.name
            }
            self.add("Connector:Splitter", inputs)
        end

        def add_mixer(name,outlet_branch,inlet_branch_array)
            inputs = { "name" => name }
            inputs["Outlet branch name"] = outlet_branch.name
            inlet_branch_array.each_with_index{|branch,index|
                inputs["Inlet Branch #{index+1} Name"] = branch.name
            }
            self.add("Connector:Mixer", inputs)
        end

    end


    class EnergyPlusObject
        def add_outlet(branch)
            raise "Fatal:  '#{self.type}' is not a Connector:Splitter" if not self.verify("Connector:Splitter") #this raises if needed     
            self.fields.each_with_index{|field,index|
                next if field.value
                field.value = branch.name
                return self
            }
            warn "Outlet not added"
        end

        def add_inlet(branch)
            raise "Fatal:  '#{self.type}' is not a Connector:Mixer" if not self.verify("Connector:Mixer") #this raises if needed     
            self.fields.each_with_index{|field,index|            
                next if field.value
                field.value = branch.name
                return self
            }
            warn "Inlet Not Added"
        end

        
    end
end
