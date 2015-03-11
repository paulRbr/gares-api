require 'grape'
require 'grape-swagger'
require 'gares'

class App < Grape::API
  format :json

  before do
    header['Access-Control-Allow-Origin'] = '*'
    header['Access-Control-Request-Method'] = '*'
  end

  helpers do
    def serialize_gare(gare, short: false)
      return nil if gare.nil? || gare.name.nil?

      result = {
        name: gare.name
      }
      if short
        more_data = {
          slug: gare.slug
        }
      else
        more_data = {
          lat: gare.lat,
          long: gare.long,
          services: gare.services,
          borne: gare.has_borne?
        }
      end
      result.merge more_data
    end
  end

  resource :gares do
    desc "Return detailed information of a gare given its slug."
    params do
      requires :slug, type: String, desc: "Slug of a gare."
    end
    route_param :slug do
      get do
        gare = Gares::Gare.new(params[:slug])

        serialize_gare(gare)
      end
    end

    desc "Return a list of gares names that match the given blob."
    params do
      requires :blob, type: String, desc: "Blob to search."
    end
    resource :search do
      route_param :blob do
        get do
          gares = Gares::Gare.search(params[:blob])

          gares.map { |gare| serialize_gare(gare, short: true) }
        end
      end

      desc "Return detailed information of a gare given its index position in the search."
      params do
        requires :id, type: Integer, desc: "Index of the gare from search."
        requires :blob, type: String, desc: "Blob to search for gares."
      end
      route_param :blob do
        route_param :id do
          get do
            gares = Gares::Search.new(params[:blob]).gares
            begin
              serialize_gare(gares[params[:id]])
            rescue
              { message: "id must be > -#{gares.size} and < #{gares.size}" }
            end
          end
        end
      end
    end
  end

  add_swagger_documentation hide_format: true
end
