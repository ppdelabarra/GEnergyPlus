require_relative "rbplus/version"
require_relative "rbplus/idd"

module EPlusModel

  def self.new(version)
    EPlusModel.new(version)
  end



  class EPlusModel
    
    def initialize(version)
      @idd_dir = File.join(File.dirname(File.expand_path(__FILE__)), 'idd')    
      @version = version      
      @idd = IDD.new("#{@idd_dir}/#{@version}.idd")
      @objects = Hash.new
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
    
    def [](object_name)
        @objects[object_name]
    end

  end #end of class
end #end of module


model = EPlusModel.new("8.6.0")
model.add("version",{"version identifier" => "8.6.0"})
model.add("zone",{"name" => "Zone number 1"})
model.add("building",Hash.new{})
model.add("zone",{"name" => "Zone number 2"})


model.print