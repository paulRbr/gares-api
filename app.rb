require 'grape'
require 'gares'

class App < Grape::API
  format :json

  resource :gares do
    desc "Return a list of gares matching the given blob."
    params do
      requires :slug, type: String, desc: "Blob to search for gares."
    end
    route_param :slug do
      get do
        gares = Gares::Search.new(params[:slug]).gares

        gares.map{ |gare| serialize_gare(gare) }
      end
    end

    desc "Return a specific gare from a gares search."
    params do
      requires :id, type: Integer, desc: "Position of the gare from search."
      requires :slug, type: String, desc: "Blob to search for gares."
    end
    route_param :slug do
      route_param :id do
        get do
          gares = Gares::Search.new(params[:slug]).gares
          begin
            serialize_gare(gares[params[:id]])
          rescue
            {message: "id must be > -#{gares.size} and < #{gares.size}"}
          end
        end
      end
    end
  end

  helpers do
    def serialize_gare(gare)
      gare.nil? ? nil : {
        name: gare.name,
        lat: gare.lat,
        long: gare.long,
        services: gare.services,
        borne: gare.has_borne?
      }
    end
  end
end
