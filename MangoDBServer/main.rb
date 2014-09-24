# ProtoType version.
# TODO:
#   -> Implement of temporaryStore
#   -> Implement custom Key
#   -> Implement custom Value
#   -> Implement string class
require 'json'
require 'sinatra'
require "sinatra/reloader" 
class MangoDB < Sinatra::Base
    configure :development do 
        register Sinatra::Reloader
    end
    temporaryStore = {}

    get '/' do
        "MangoDB Running on port #{Sinatra::Application.port}"
    end

    get '/get/:key' do
        content_type :json
        temporaryStore["h"] = "Mangoes are yellow"
        ret = temporaryStore[params[:key]]
        ret.to_json
    end

    post '/put' do
        temporaryStore[params[:key]] = params[:value]
    end

    post '/delete' do
        temporaryStore.delete(params[:key])
    end

end

MangoDB.run!
