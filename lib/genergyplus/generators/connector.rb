
module EPlusModel

    class Model
        
        # Adds a new Branch List to the model. An array of branches should be passed        
        #
        # @author Germán Molina
        # @param name [String] The name to assign to the material
        # @param branch_array [<EnergyPlusObject>] The array of branches to assign
        # @return [EnergyPlusObject] The created branch list
        def add_branch_list(name,branch_array)
            inputs = { "name" => name }
            branch_array.each_with_index{|branch,index|
                inputs["Branch #{index+1} Name"]=branch.name
            }
            self.add("branchlist",inputs)
        end

        # Adds a new connector list to the model. An array of connectors should be passed        
        #
        # @author Germán Molina
        # @param name [String] The name to assign to the material
        # @param connector_array [<EnergyPlusObject>] The array of connector to assign        
        # @return [EnergyPlusObject] The created connector list
        def add_connector_list(name,connector_array)
            inputs = { "name" => name }
            connector_array.each_with_index{|connector,index|
                inputs["Connector #{index + 1} Object Type"]=connector.name
                inputs["Connector #{index + 1} name"]=connector.name
            }
            self.add("ConnectorList",inputs)
        end

        # Adds a new splitter to the model. It has a single inlet and a 
        # as many outlet as passed. It can be extended with the "add outlet" method      
        #
        # @author Germán Molina
        # @param name [String] The name to assign to the material
        # @param inlet_branch [EnergyPlusObject] The inlet branch
        # @param outlet_branch_array [<EnergyPlusObject>] The outlet branch array        
        # @return [EnergyPlusObject] The created splitter
        def add_splitter(name,inlet_branch,outlet_branch_array)
            inputs = { "name" => name }
            inputs["Inlet branch name"] = inlet_branch.name
            outlet_branch_array.each_with_index{|branch,index|
                inputs["Outlet Branch #{index+1} Name"] = branch.name
            }
            self.add("Connector:Splitter", inputs)
        end

        # Adds a new mixer to the model. It has a single outlet and a 
        # as many inlets as passed. It can be extended with the "add inlet" method      
        #
        # @author Germán Molina
        # @param name [String] The name to assign to the material
        # @param outlet_branch [EnergyPlusObject] The outlet branch
        # @param inlet_branch_array [<EnergyPlusObject>] The inlet branch array
        # @return [EnergyPlusObject] The created mixer
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
        
        # Extends a splitter by adding a new outlet branch.
        #
        # @author Germán Molina
        # @param branch [EnergyPlusObject] the branch to add
        # @return [EnergyPlusObject] The splitter itself
        def add_outlet(branch)
            raise "Fatal:  '#{self.type}' is not a Connector:Splitter" if not self.verify("Connector:Splitter") #this raises if needed     
            self.fields.each_with_index{|field,index|
                next if field.value
                field.value = branch.name
                return self
            }
            warn "Outlet not added"
        end

        # Extends a mixer by adding a new inlet branch.
        #
        # @author Germán Molina
        # @param branch [EnergyPlusObject] the branch to add
        # @return [EnergyPlusObject] The inlet itself
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
