require 'open-uri'
require 'json'


artist_list = []
artist_count = 0
artist_name = "init"

# Establish Metro Area
result_check = []
until !result_check.empty?
  puts "Name a metro area that you live near:"
  cityquery = gets.chomp
  city_path = "http://api.songkick.com/api/3.0/search/locations.json?query=#{cityquery}&apikey=vRLjJK39RWRYVc9x"
  city_results = JSON.parse(open(city_path).read)
  result_check = city_results.fetch("resultsPage").fetch("results")
  if result_check.empty? 
    puts "Invalid Entry, please try again."
  end
end
metro_list = city_results.fetch("resultsPage").fetch("results").fetch("location")
metro_count = 0
metro_table = []
metro_list.each do |metro|
  metro_area = metro.fetch("metroArea")
  metro_city = metro_area.fetch("displayName")
  metro_country = metro_area.fetch("country").fetch("displayName")
  if metro_country == "US"
    metro_state = metro_area.fetch("state").fetch("displayName")
    metro_name = "#{metro_city}, #{metro_state}, #{metro_country}"
  else
    metro_state = nil
    metro_name = "#{metro_city}, #{metro_country}"
  end
  location_id = metro_area.fetch("id")
  metro_found = false
  metro_table.each do |entry|
    if entry[:location_id] == location_id
      metro_found = true
    end
  end
  if !metro_found
    metro_count += 1
    metro_table << {:id => metro_count, :name => metro_name, :location_id => location_id}
  end
end
metro_table.each do |metro|
  puts "#{metro[:id]} - #{metro[:name]} - #{metro[:location_id]}"
end
  city_results = JSON.parse(open(city_path).read)

#Get valid metro_id
valid_metro_id = false
until valid_metro_id
  puts "Which metro area are you in (enter #)?"
  metro_id = gets.chomp.to_i
  metro_id = metro_id - 1
  if metro_id >= 0 && metro_id <= (metro_count - 1)
    valid_metro_id = true
  else
    puts "Invalid entry, please try again"
  end
end
my_metro = metro_table[metro_id]
sk_location_id = my_metro[:location_id]

# Enter Favorite Artists
until artist_name.downcase == "done"
  if artist_count == 0
    puts "Enter an artist that you like:"
  else
    puts "You have entered #{artist_count} artist#{"s" if artist_count > 1}"
    puts "Enter another artist or type DONE to see results"
  end
  artist_name = gets.chomp
  artist_name.sub! ' ', '+'
  if artist_name.downcase != "done"
    artist_list << artist_name
    artist_count += 1
  end
end

queries = artist_list

#Compile list of Suggestions
suggestions = []
queries.each do |query|
  path = "http://developer.echonest.com/api/v4/artist/similar?api_key=7B2DCIZJX0PVRLNXJ&name=#{ query }&format=json&results=100&start=0&bucket=hotttnesss&bucket=discovery"
  results = JSON.parse(open(path).read)
  artists = results.fetch("response").fetch("artists")
  artists.each do |artist|
    name = artist.fetch("name")
    hotttnesss = artist.fetch("hotttnesss")
    discovery = artist.fetch("discovery")
    found = false
    suggestions.each do |suggestion|
      if suggestion[:name] == name
        suggestion[:count] += 1
        found = true
      end
    end
    if !found
      suggestions << {:name => name, :hotttnesss => hotttnesss, :discovery => discovery, :count => 1}
    end
  end
end
sorted_suggestions = suggestions.sort_by { |k| k[:count] }.reverse!
sorted_suggestions.each do |suggestion|
  # Prepare Event Query
  artist_query = suggestion[:name].downcase
  artist_query.sub! ' ', '+'
  artist_query.sub! '&', "and"
  #artist_query.encode!(Encoding::ASCII_8BIT)
  event_path = "http://api.songkick.com/api/3.0/events.json?apikey=vRLjJK39RWRYVc9x&artist_name=#{artist_query}&location=sk:#{sk_location_id}"
  event_response = JSON.parse(open(event_path).read)
  event_results = event_response.fetch("resultsPage").fetch("results")
  
  if !event_results.empty?
    event_list = event_results.fetch("event")
    percentage = (suggestion[:count].to_f/artist_count.to_f)*100
    #puts "#{ suggestion[:name] } --- #{ percentage.round(2) }% --- #{ suggestion[:hotttnesss] } --- #{ suggestion[:discovery] } "
    puts suggestion[:name].upcase
    event_list.each do |event|
      event_name = event.fetch("displayName")
      event_venue = event.fetch("venue").fetch("displayName")
      event_city = event.fetch("location").fetch("city")
      event_date = event.fetch("start").fetch("date")
      event_time = event.fetch("start").fetch("time")
      puts event_name
      puts event_venue
      puts event_city
      puts "#{event_date} at #{event_time}\n\n"
    end
  else
    #puts "No events found for #{suggestion[:name]}"
  end
end  
