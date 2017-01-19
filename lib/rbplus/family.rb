module EPlusModel      
    module Family

        @@data = Hash.new

        @@data["Roof and Ceiling"] = [        
                                      "Roof",                        
                                      "Ceiling:Adiabatic", 
                                      "Ceiling:Interzone", 
                                      "Floor:GroundContact", 
                                      "Floor:Adiabatic", 
                                      "Floor:Interzone", 
                                      "Buildingsurface:detailed",
                                      "RoofCeiling:Detailed",
                                      "Floor:Detailed",
                                    ]

        @@data["All Geometry"] =  [  
                                    # Required for a correct geometry interpretation
                                    "GlobalGeometryRules",

                                    #What we want to describe
                                    "Zone", 

                                    # Surfaces      
                                    ## Walls                
                                    "Wall:Exterior",
                                    "Wall:Adiabatic",
                                    "Wall:Underground",
                                    "Wall:Interzone",

                                    ## Roof / Ceiling
                                    "Roof",
                                    "Ceiling:Adiabatic",
                                    "Ceiling:Interzone",

                                    "Floor:GroundContact",
                                    "Floor:Adiabatic",
                                    "Floor:Interzone",

                                    ## Windows/Doors
                                    "Window",
                                    "Door",
                                    "GlazedDoor",
                                    "Window:Interzone",
                                    "Door:Interzone",
                                    "GlazedDoor:Interzone",

                                    # Building Surfaces - Detailed
                                    "Wall:Detailed",
                                    "RoofCeiling:Detailed",
                                    "Floor:Detailed",
                                    "BuildingSurface:Detailed",                       
                                    "FenestrationSurface:Detailed",                       

                                    #Internal mass
                                    "InternalMass",

                                    # Detached shading Surfaces
                                    "Shading:Site",
                                    "Shading:Building",                      
                                    "Shading:Site:Detailed",
                                    "Shading:Building:Detailed",

                                    # Attached shading surfaces
                                    "Shading:Overhang",
                                    "Shading:Overhang:Projection",
                                    "Shading:Fin",
                                    "Shading:Fin:Projection",
                                    "Shading:Zone:Detailed",
                                    
                                ]

            def self.get_family_members(description)            
                @@data.each{|key,value|
                    return value if key.downcase.strip == description.downcase.strip
                }
                return false
            end 
        
    end
end