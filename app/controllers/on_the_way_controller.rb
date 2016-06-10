require 'open-uri'


class OnTheWayController < ApplicationController
  def enter_address_form
    # Nothing to do here.
  end

  def waypoint
    # @way_lat=@response.business.location.coordinate.latitude
    # @way_long=@response.business.location.coordinate.latitude
    @start_address = params[:start_address]
    @end_address = params[:end_address]
    @waypoint=params[:waypoint]
    @term=params[:term]
    @sort_method=params[:sort_method]
    @name=params[:name]
  end

  def street_to_coords
    @start_address = params[:start_address]
    url_safe_start_address = URI.encode(@start_address)

    @end_address = params[:end_address]
    url_safe_end_address = URI.encode(@end_address)

    @term = params[:term]
    @sort_method=params[:sort_method]
    @waypoint=params[:waypoint]

    require 'JSON'
    start_url="http://maps.googleapis.com/maps/api/geocode/json?address="+url_safe_start_address
    parsed_data = JSON.parse(open(start_url).read)
    @start_latitude = parsed_data["results"][0]["geometry"]["location"]["lat"]
    @start_longitude = parsed_data["results"][0]["geometry"]["location"]["lng"]
    @start_add = parsed_data["results"][0]["formatted_address"]

    end_url="http://maps.googleapis.com/maps/api/geocode/json?address="+url_safe_end_address
    parsed_data = JSON.parse(open(end_url).read)
    @end_latitude = parsed_data["results"][0]["geometry"]["location"]["lat"]
    @end_longitude = parsed_data["results"][0]["geometry"]["location"]["lng"]
    @end_add = parsed_data["results"][0]["formatted_address"]
    @center_lat = (@end_latitude + @start_latitude)/2
    @center_long = (@end_longitude + @start_longitude)/2

    require 'yelp'
    @client = Yelp::Client.new({ consumer_key: "WkYx-EJrUVkDdwgWRCAepQ",
      consumer_secret: "fR7Yr5eBPyGkks0SwVAEbrRw_W0",
      token:"KlgcLX0qtuBSvMx8cdbMmHpYCNEIRylV",
      token_secret: "Bu_toCiXGobmBNx5CMwHnM1Woeo" })
      # @coordinates = { latitude: @center_lat, longitude: @center_long }
      @coordinates = { latitude: @center_lat, longitude: @center_long }

      if @start_latitude>@end_latitude
        @sw_lat=@start_latitude
        @ne_lat=@end_latitude
      else
        @sw_lat=@end_latitude
        @ne_lat=@start_latitude
      end

      if @start_longitude<@end_longitude
        @sw_long=@start_longitude
        @ne_long=@end_longitude
      else
        @sw_long=@end_longitude
        @ne_long=@start_longitude
      end

      @params = { term: @term,
        limit: 5,
        sort:@sort_method,
        radius_filter:500,
      }
      #
      @locale = { lang: 'en' }

      @bounding_box = { sw_latitude: @sw_lat, sw_longitude: @sw_long, ne_latitude: @ne_lat, ne_longitude: @ne_long }
      @response=@client.search_by_bounding_box(@bounding_box, @params, @locale)
      #@response=@client.search_by_coordinates(@coordinates, @params,@locale)


      # responses_string = JSON[response]
      # response_string do |business|
      # @business_name=response_string["business"][0]["name"]
      #
      # end



      # function getCoordinates(result) {
      #       var currentRouteArray = result.routes[0];  //Returns a complex object containing the results of the current route
      #       var currentRoute = currentRouteArray.overview_path; //Returns a simplified version of all the coordinates on the path
      #
      #
      #       obj_newPolyline = new google.maps.Polyline({ map: map }); //a polyline just to verify my code is fetching the coordinates
      #       var path = obj_newPolyline.getPath();
      #       for (var x = 0; x < currentRoute.length; x++) {
      #           var pos = new google.maps.LatLng(currentRoute[x].kb, currentRoute[x].lb)
      #           latArray[x] = currentRoute[x].lat(); //Returns the latitude
      #           lngArray[x] = currentRoute[x].lng(); //Returns the longitude
      #           path.push(pos);
      #       }
      # }

      render("street_to_coords.html.erb")
    end
  end
