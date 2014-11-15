# ProtoType version.
# TODO:
#   -> Implement of temporaryStore
#   -> Implement custom Key
#   -> Implement custom Value
#   -> Implement string class

require 'json'
require 'sinatra'
class MangoDB < Sinatra::Base
  enable :logging

  temporaryStore = {}

  # Show present configuration of MangoDB.
  get '/' do
    "MangoDB Running on port #{Sinatra::Application.port}"
  end

  get '/get/:key' do
    content_type :json
    ret = temporaryStore[params[:key].to_s]
    JSON.dump temporaryStore
  end

  post '/put' do
    hash = JSON.parse params["hash"]
    logger.info hash.inspect
    hash.each { |k,v| temporaryStore[k.to_s] = v }
    "OK"
  end

  post '/delete' do
    temporaryStore.delete(params[:key])
    "OK"
  end

  # Function to test if the server is alive.
  get '/ping' do
    "pong"
  end

end

MangoDB.run!
