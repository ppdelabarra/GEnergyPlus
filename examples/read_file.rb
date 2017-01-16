require_relative "../lib/rbplus"

if ARGV.length != 1
    warn "USAGE: ruby read_file.rb 'NAME_OF_FILE_TO_READ'"
end

model = EPlusModel.new_from_file(ARGV[0])

model.print