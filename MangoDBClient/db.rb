require 'net/http'
require 'json'

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
    if response != 'null'
      response
    else
      nil
    end
  end

  alias :[] :get

  def []=(key, value)
    insert({key.to_sym => value})
  end

  def close
    @request[:operation] = 'close'
    r = make_request
    @request[:name] = nil
    r
  end

  def commit
    @request[:operation] = 'commit'
    make_request
  end

  def ping
    Net::HTTP.get(URI(@uri[0..-3] + "ping"))
  end

  def initialize(ip = 'localhost', port = 9292)
    @ip = ip
    @port = port
    @uri = "http://#{@ip.to_s}:#{@port.to_s}/op"
    @request = { operation: "", name: "", key: "", value: "" }
  end

  def finalize
    commit
    @fd.close
  end

  private
    def make_request
      response = Net::HTTP.post_form(URI(@uri), "hash" => JSON.dump(@request))
      if response.code.to_i == 200
        JSON.parse(response.body)["response"]
      else
        "#{response.code} : #{response.body}"
      end
    end
end
