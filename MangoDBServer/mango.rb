require 'bunny'
require 'json'

class Mango
  attr_reader :reply_queue
  attr_accessor :response, :call_id
  attr_reader :lock, :condition

  def initialize(ch, server_queue)
    @ch = ch
    @x = ch.default_exchange
    @server_queue = server_queue
    @reply_queue = ch.queue("", exclusive: true)
    @lock = Mutex.new
    @condition = ConditionVariable.new
    that = self
    @reply_queue.subscribe do |delivery_info, properties, payload|
      if properties[:correlation_id] == that.call_id
        that.response = payload
        that.lock.synchronize{that.condition.signal}
      end
    end
  end

  def open(args)
    args["operation"] = "open"
    call(args)
  end

  def get(args)
    args[:operation] = "get"
    call(args)
  end

  def put(args)
    args[:operation] = "put"
    call(args)
  end

  def commit(args)
    args[:operation] = "commit"
    call(args)
  end

  def call(args)
    args = JSON.dump(args)
    self.call_id = random_key
    @x.publish(args.to_s, routing_key: @server_queue, correlation_id: call_id, reply_to: @reply_queue.name)
    lock.synchronize{condition.wait(lock)}
    response
  end

  protected

  def random_key
    (0...10).map { ('a'..'z').to_a[rand(26)] }.join
  end

end

