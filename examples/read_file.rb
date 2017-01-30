require_relative "../lib/genergyplus"

if ARGV.length != 1
    warn "USAGE: ruby read_file.rb 'NAME_OF_FILE_TO_READ'"
end

idf_file=ARGV[0]

model = EPlusModel.new_from_file(idf_file)  

model.print
