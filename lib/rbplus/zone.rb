module EPlusModel      
    class EnergyPlusObject


        def add_something            
            self.verify("zone") #this raises if needed

            EPlusModel.model.add("zone",{"name" => "Zone number 3", "z origin" => 142})

        end

    end
end