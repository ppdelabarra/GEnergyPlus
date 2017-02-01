module EPlusModel    

    # A module that contains groups and families within the EnergyPlus objects.
    # 
    # For example, interior walls may be Wall:Interzone, Wall:Detailed, Wall:Adiabatic 
    # and BuildingSurface:Detailed. All these are grouped within the family "Interior Walls"
    #  
    module Family

        @@data = Hash.new

        @@data["Walls"] =   [
                                "Wall:Exterior",
                                "Wall:Adiabatic",
                                "Wall:Underground",
                                "Wall:Interzone",
                                "Wall:Detailed",
                                "BuildingSurface:Detailed", #Check that it is a wall
                            ]
        @@data["Interior Walls"] =  [                                        
                                        "Wall:Interzone",
                                        "Wall:Detailed", #endure that it is interior
                                        "Wall: Adiabatic", 
                                        "BuildingSurface:Detailed", # Check that is an interior wall|                                        
                                    ]  
        @@data["Exterior Walls"] =  [
                                        "Wall:Exterior",
                                        "Wall:Adiabatic",
                                        "BuildingSurface:Detailed",
                                    ]          
        @@data["Underground Walls"] =   [
                                            "Buildingsurface:Detailed",
                                            "Wall:Underground"
                                        ]

        @@data["Fenestration"] = [
                                    "Window",
                                    "Door",
                                    "GlazedDoor",
                                    "Window:Interzone",
                                    "Door:Interzone",
                                    "GlazedDoor:Interzone",
                                    "FenestrationSurface:Detailed",     
                                 ]                  
        @@data["Windows"] = [
                                "Window",                                
                                "Window:Interzone",    
                                "FenestrationSurface:Detailed",     
                            ]         

        @@data["Exterior windows"] = [
                                        "Window",                                                                           
                                        "FenestrationSurface:Detailed",   
                                     ]        

        @@data["Interior windows"] = [
                                        "Window:Interzone",                                                                           
                                        "FenestrationSurface:Detailed",   
                                     ]                                                                                      

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
                                    "FenestrationSurface:Detailed",     

                                    # Building Surfaces - Detailed
                                    "Wall:Detailed",
                                    "RoofCeiling:Detailed",
                                    "Floor:Detailed",
                                    "BuildingSurface:Detailed",                       
                                                      

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
            
            # Retrieves a family.
            #
            # @author Germán Molina
            # @param description [String] The name of the family
            # @return [<String>] An array with the types of objects in such family
            def self.get_family_members(description)            
                @@data.each{|key,value|
                    return value if key.downcase.strip == description.downcase.strip
                }
                return false
            end 
        
    end
end