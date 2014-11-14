require "net/http"
require "json"

class DB
  attr_accessor :port, :ip, :uri
  def insert hash
    Net::HTTP.post_form(URI(@uri + "/put"), "hash" => JSON.dump(hash))
  end

  def delete key
    Net::HTTP.post_form(URI(@uri + "/delete"), "key" => key)
  end

  def get key
    response = Net::HTTP.get(URI(@uri + "/get/#{key}"))
    response.strip!
    if response != 'null'
      JSON.parse response
      response
    else
      nil
    end
  end

  def initialize(ip, port)
    @ip = ip
    @port = port
    @uri = "http://" + @ip.to_s + ":" + @port.to_s
  end
end

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

