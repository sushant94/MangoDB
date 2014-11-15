require "net/http"
require "json"
require_relative "db.rb"

binding = binding()

while true
  print "MangoDB > "
  input = STDIN.gets.chomp!
  begin
    result = eval(input, binding)
    puts "  -> " + result.to_s
  rescue Exception => e
    break if input == 'exit'
    puts e.class.to_s + ": " + e.message.to_s
  end
end

