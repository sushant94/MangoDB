require 'json'
require 'sinatra'
require "bunny"

require File.expand_path("../mango.rb", __FILE__)

class MangoDB < Sinatra::Base
  enable :logging

  conn = Bunny.new(automatically_recover: false, heartbeat: 10)
  conn.start
  ch = conn.create_channel
  ch.prefetch(1)
  mango = Mango.new(ch, "rpc_queue")

  # Show present configuration of MangoDB.
  get '/' do
    "MangoDB Running on port #{Sinatra::Application.port}"
  end

  post '/op' do
    args = JSON.parse params["hash"]
    mango.call(args)
  end

#  post '/get' do
#    content_type :json
#    args = JSON.parse params["hash"]
#    mango.get(args)
#  end
#
#  post '/open' do
#    name = JSON.parse params["hash"]
#    logger.info name.inspect
#    mango.open(name)
#  end
#
#  post '/put' do
#    hash = JSON.parse params["hash"]
#    logger.info hash.inspect
#    hash.each { |k,v| temporaryStore[k.to_s] = v }
#    "OK"
#  end
#
#  post '/delete' do
#    temporaryStore.delete(params[:key])
#    "OK"
#  end

  # Function to test if the server is alive.
  get '/ping' do
    "pong"
  end

end

MangoDB.run!
