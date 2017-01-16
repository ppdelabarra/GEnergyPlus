module EPlusModel

  class Model
    
    def initialize(version)
      @idd_dir = File.join(File.dirname(File.expand_path(__FILE__)), 'idd_files')    
      @version = version      
      raise "Fatal: Wrong EnergyPlus version... IDD file not found or not supported" if not File.file? "#{@idd_dir}/#{@version}.idd"
      @idd = IDD.new("#{@idd_dir}/#{@version}.idd")
      @objects = Hash.new

      self.add("version",{"version identifier" => version})
    end

    def add(object_name, inputs)
      object = @idd[object_name.downcase] #this raises an error if the object does not exist      
      object.check_input(inputs)  #this raises if there is an error
      
      if object.unique then
        if @objects.key? object_name.downcase then
          raise "Trying to replace unique object '#{object_name}'"
        else
          @objects[object_name.downcase] = object.create(inputs)     
        end
      else
        if @objects.key? object_name.downcase then
          @objects[object_name.downcase] << object.create(inputs)  
        else
          @objects[object_name.downcase] = [object.create(inputs)]     
        end
      end
    end

    def print 
      @objects.each{|key,value|    
        if value.is_a? Array then
          value.each{|i| i.print}
        else    
          value.print
        end
        puts ""        
      }
    end

    def describe(object_name) 
      object = @idd[object_name.downcase] #this raises an error if the object does not exist 
      object.help
    end

    def get_definition(object_name)
        @idd[object_name.downcase] #this raises an error if the object does not exist 
    end
    
    def find(query)
      @idd.keys.select{|x| x.downcase.include? query.downcase}      
    end
    
    def [](object_name)
        @objects[object_name]
    end

  end #end of class

end