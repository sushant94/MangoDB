class DB
  attr_accessor :port, :ip, :uri

  def create(name)
    @request[:operation] = 'create'
    @request[:name] = name
    make_request
  end

  def keys
    @request[:operation] = 'keys'
    make_request
  end

  def select(name)
    @request[:operation] = 'open'
    @request[:name] = name
    make_request
  end

  def insert(hash)
    @request[:operation] = 'put'
    @request[:key] = hash.keys[0]
    @request[:value] = hash.values[0]
    make_request
  end

  def delete(key)
    @request[:operation] = 'insert'
    @request[:key] = key
    @request[:value] = nil
    make_request
  end

  def get(key)
    @request[:operation] = 'get'
    @request[:key] = key
    response = make_request
    response.strip!
    if response != 'null'
      JSON.parse response
      response
    else
      nil
    end
  end

  def commit
    @request[:operation] = 'commit'
    make_request
  end

  def ping
    response = Net::HTTP.get(URI(@uri[0..-3] + "ping"))
  end

  def initialize(ip, port)
    @ip = ip
    @port = port
    @uri = "http://#{@ip.to_s}:#{@port.to_s}/op"
    @request = { operation: "", name: "", key: "", value: "" }
  end

  private:
    def make_request
      response = Net::HTTP.post_form(URI(@uri), "hash" => JSON.dump(@request))
      JSON.parse(response)
    end
end
