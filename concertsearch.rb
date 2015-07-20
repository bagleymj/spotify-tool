require 'open-uri'
require 'json'


artist_list = []
artist_count = 0
artist_name = "init"
puts "Name a metro area that you live near:"
cityquery = gets.chomp
city_path = "http://api.songkick.com/api/3.0/search/locations.json?query=#{cityquery}&apikey=vRLjJK39RWRYVc9x"
city_results = JSON.parse(open(city_path).read)
metro_list = city_results.fetch("resultsPage").fetch("results").fetch("location")
metro_count = 0
metro_table = []
puts "Which metro area are you in?"
metro_list.each do |metro|
  metro_name = "#{metro.fetch("metroArea").fetch("displayName")}, #{metro.fetch("metroArea").fetch("country").fetch("displayName")}"
  location_id = metro.fetch("metroArea").fetch("id")
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

#Calculate!
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
sorted_suggestions[0..9].each do |suggestion|
  percentage = (suggestion[:count].to_f/artist_count.to_f)*100
  puts "#{ suggestion[:name] } --- #{ percentage.round(2) }% --- #{ suggestion[:hotttnesss] } --- #{ suggestion[:discovery] } "
end  
