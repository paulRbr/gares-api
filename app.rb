require 'sinatra/base'
require 'sinatra/json'
require 'gares'

class App < Sinatra::Base
  helpers Sinatra::JSON

  get '/gare/:slug' do
    gare = Gares::Search.new(params[:slug]).gares.last
    if gare
      json gare: {
        name: gare.name,
        borne: gare.has_borne?
      }
    else
      json gare: nil
    end
  end
end
