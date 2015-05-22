## API using the 'gares' ruby gem

This is a simple API to show what you can do with the ['gares' gem](https://github.com/paulrbr/gares)

### Try it out

#### Stations

- Search train stations with "paris": http://gares-railrail.rhcloud.com/stations/search/paris

```
GET http://gares-railrail.rhcloud.com/stations/search/[query]
```

- Get info for the second result of that search: http://gares-railrail.rhcloud.com/stations/search/paris/2

```
GET http://gares-railrail.rhcloud.com/stations/search/[query]/[index]
```

- Get info from a specific train station given it's sncf_id: http://gares-railrail.rhcloud.com/stations/frlpd

```
GET http://gares-railrail.rhcloud.com/stations/[sncf_id]
```

- Get all departing/arriving trains from a given train station: http://gares-railrail.rhcloud.com/stations/frmpl/departures


```
GET http://gares-railrail.rhcloud.com/stations/[sncf_id]/(departures|arrivals)
```

#### Trains

- Get live train information given it's number and date: http://gares-railrail.rhcloud.com/train/17687/2015-05-22
```
GET http://gares-railrail.rhcloud.com/train/[train_number]/[date]
```


### Swagger compliant

The api is swagger compliant you can visit [petstore.swagger.io](http://petstore.swagger.io) and give "http://gares-railrail.rhcloud.com/swagger_doc" as the API url. It will give you a documentation of the API.
