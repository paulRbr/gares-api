require 'grape'
require 'grape-swagger'
require 'json'
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
          sncf_id: gare.sncf_id
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

    def serialize_train(train, short: false)
      return nil if train.nil?

      result = {
        number: train.number,
        date: train.date,
      }
      more_data = {
        delayed: train.delayed?
      }
      unless short
        more_data.merge!(
          from: {
            station: serialize_gare(train.departure.station, short: true),
            platform: train.departure.platform
          },
          stops: train.stops.map{ |stop| { station: serialize_gare(stop.station, short: true), platform: stop.platform } },
          to: {
            station: serialize_gare(train.arrival.station, short: true),
            platform: train.arrival.platform
          },
          departure_date: train.departure.departure_date,
          arrival_date: train.arrival.arrival_date,
        )
      end
      result.merge more_data
    end
  end

  resource :stations do
    desc "Return detailed information of a station given its sncf_id."
    params do
      requires :sncf_id, type: String, desc: "Sncf_id of a station."
    end
    route_param :sncf_id do
      get do
        gare = Gares::Station.search_by_sncf_id(params[:sncf_id]).first

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
          gares = Gares::Station.search(params[:blob])

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
            gares = Gares::Station.search(params[:blob])
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

  resource :train do
    desc "Return detailed information about a train given its number and date."
    params do
      requires :number, type: Integer, desc: "Train number."
      requires :date,   type: String, desc: "Train date in YYYY-MM-DD format.", allow_blank: false, regexp: /^[0-9]{4}-[0-1][0-9]-[0-3][0-9]$/
    end
    route_param :number do
      route_param :date do
        get do
          begin
            train = Gares::Train.new(params[:number], Time.parse(params[:date]))

            serialize_train(train)
          rescue Gares::TrainNotFound => e
            { :error => e.message }
          end
        end
      end
    end
  end

  add_swagger_documentation hide_format: true
end
