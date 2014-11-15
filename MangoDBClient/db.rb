class DB
  attr_accessor :port, :ip, :uri, :namespace

  def insert hash
    @request[:operation] = 'put'
    @request[:name] = @namespace
    @request[:key] = hash.keys[0]
    @request[:value] = hash.values[0]
    Net::HTTP.post_form(URI(@uri + "/put"), "hash" => JSON.dump(@request))
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

  def ping
    response = Net::HTTP.get(URI(@uri + "/ping"))
  end

  def initialize(ip, port)
    @ip = ip
    @port = port
    @uri = "http://" + @ip.to_s + ":" + @port.to_s
    @request = { operation: "", name: "", key: "", value: "" }
  end
end
