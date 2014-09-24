require 'sinatra'
get '/' do
    "MangoDB Running on port #{Sinatra::Application.port}"
end
