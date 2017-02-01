require "bundler/gem_tasks"

task :doc do
    warn `yardoc lib/*.rb lib/*/*.rb lib/*/*/*.rb`
end

def gem_file
    Dir["*.gem"].shift
end

def version_file
    return "./lib/genergyplus/version.rb"
end

def get_version
    file = File.readlines(version_file)
    file[2].split("=").pop.strip
end

def increase_version(i)
    old_v = get_version
    new_v = old_v.split(".").map{|x| x.to_i}
    new_v[i]+=1
    warn "Increasing to version #{new_v.join(".")}"
    return new_v.join(".")
end

def set_version(version)
    File.open(version_file,'w'){|f|
       f.puts "module EPlusModel
    # Version Constant
    VERSION = '#{version}'
end"
    }
end

def new_release(type) 
    warn "Releasing new #{type} version"
    i = ["major","minor","patch"].find_index(type) 
    warn `git add .`   
    set_version increase_version(i)    
    warn `gem build genergyplus.gemspec`   
    warn `git add .`
    warn `git commit -m "New #{type} release... #{get_version}"`
    warn `git push`    
    warn `gem push #{gem_file}`
end

task :clean_gem_file do
    file = gem_file
    next if file == nil
    File.delete(file)
end


task :new_patch_release => [:doc, :clean_gem_file ] do        
    new_release("patch")    
end

task :new_minor_release => [:doc, :clean_gem_file ] do    
    new_release("minor") 
end

task :new_major_release => [:doc, :clean_gem_file ] do    
    new_release("major") 
end