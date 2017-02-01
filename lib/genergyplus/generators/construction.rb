module EPlusModel      
    class Model
        
        def add_construction(name,material_array)            
            inputs = { "name" => name }
            raise "Fatal: An array of materials is needed for creating a construction" if not material_array.is_a? Array

            inputs["Outside Layer"] = material_array.shift.name
            material_array.each_with_index{|material, index|
                inputs["Layer #{index + 2}"] = material.name
            }

            EPlusModel.model.add("Construction",inputs)
        end
    end
end