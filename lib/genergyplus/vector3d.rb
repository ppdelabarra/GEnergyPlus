module EPlusModel   
    class Vector3d
        attr_accessor :x, :y, :z

        def initialize(x,y,z)
            @x = x
            @y = y
            @z = z
        end
        
        def add(vector2)
            x = self.x + vector2.x
            y = self.y + vector2.y
            z = self.z + vector2.z
            return Vector3d.new(x,y,z)
        end

        def substract(vector2)
            x = self.x - vector2.x
            y = self.y - vector2.y
            z = self.z - vector2.z
            return Vector3d.new(x,y,z)
        end

        def length
            return Math.sqrt(@x*@x + @y*@y + @z*@z)
        end

        def dot(vector2)
            return self.x*vector2.x + self.y*vector2.y + self.z*vector2.z
        end

        def cross(vector2)
            x = self.y * vector2.z - self.z*vector2.y
            y = self.z * vector2.x - self.x*vector2.z
            z = self.x * vector2.y - self.y*vector2.x
            return Vector3d.new(x,y,z)
        end

        def reverse!
            self.x *= -1
            self.y *= -1
            self.z *= -1
        end            

        def reverse
            return Vector3d.new(self.x*-1,self.y*-1,self.z*-1)
        end

        def normalize
            length = self.length
            return Vector3d.new(self.x/length, self.y/length,self.z/length)
        end

        def normalize!
            length = self.length
            self.x/=length
            self.y/=length
            self.z/=length
        end

        def same_direction?(vector2)
            v1 = self.normalize
            v2 = vector2.normalize
            small = 1e-6
            return false if (v1.x-v2.x).abs > small
            return false if (v1.y-v2.y).abs > small
            return false if (v1.z-v2.z).abs > small
            return true        
        end

    end
end