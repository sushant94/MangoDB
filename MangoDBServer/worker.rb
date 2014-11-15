require "bunny"
require 'json'
require File.expand_path "../namespace.rb", __FILE__

conn = Bunny.new(host: "localhost", heartbeat: 10)
conn.start

ch = conn.create_channel

class Worker

  def initialize(ch)
    @ch = ch
    @namespaces = {}
  end

  def start(queue_name)
    @q = @ch.queue(queue_name)
    @x = @ch.default_exchange

    # Make the server subscribe to the channel.
    # payload is the message from the sender.
    @q.subscribe(block: true) do |delivery_info, properties, payload|
      payload = JSON.parse(payload)
      response = JSON.dump self.respond(payload)
      @x.publish(response.to_s, routing_key: properties.reply_to, correlation_id: properties.correlation_id)
    end
  end

  def respond(payload)
    # Match request to correct functions
    case payload["operation"]
    when "put"
      self.put(payload["name"], payload["key"], payload["value"])
    when "get"
      self.get(payload["name"], payload["key"])
    when "open"
      self.open_namespace(payload["name"])
    when "commit"
      self.commit(payload["name"])
    else
      "Invalid"
    end
  end

  def open_namespace(name)
    if !@namespaces[name].nil?
      return "OK"
    end
    namespace = Namespace.new(name)
    @namespaces[name] = namespace
    if namespace.nil?
      "Namespace ERROR: No such Namespace"
    else
      "OK"
    end
  end

  def get(name, key)
    if @namespaces[name].nil?
      "Namespace ERROR: No Namespace selected"
    else
      @namespaces[name][key]
    end
  end

  def put(name, key, value)
    if @namespaces[name].nil?
      "Namespace ERROR: No Namespace selected"
    else
      @namespaces[name][key] = value
    end
  end

  def commit(name)
    if @namespaces[name].nil?
      "Namespace ERROR: No Namespace selected"
    else
      @namespaces[name].commit
    end
  end

end

begin
  server = Worker.new(ch)
  puts " [x] Awaiting requests"
  server.start("rpc_queue")
rescue Interrupt=>_
  ch.close
  conn.close
end
