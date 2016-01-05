require 'json'
require './lib/npm.rb'


class App < Sinatra::Base

  get "/:npm" do 
    content_type :json
    npm = NPM.new(params[:npm])
    npm.all_dependencies.to_json
  end
end
