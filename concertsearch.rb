require 'open-uri'
require 'json'

#Get User Input
queries = []
puts "Name an artist you are currently into..."
queries << gets
puts "Name another artist..."
queries << gets
puts "Name one more artist..."
queries << gets

#Calculate!
suggestions = []
queries.each do |query|
  path = "https://api.spotify.com/v1/search?type=artist&q=" + query
  results = JSON.parse(open(path).read)
  artists = results.fetch("artists").fetch("items")
  artist = artists.first
  id = artist.fetch("id")
  related_path = "https://api.spotify.com/v1/artists/" + id + "/related-artists"
  related_results = JSON.parse(open(related_path).read)
  related_artists = related_results.fetch("artists")
  related_artists.each do |artist|
    name = artist.fetch("name")
    found = false
    suggestions.each do |suggestion|
      if suggestion[:name] == name
        suggestion[:count] += 1
        found = true
      end
    end
    if !found
      suggestions << {:name => name, :count => 1}
    end
  end
end
sorted_suggestions = suggestions.sort_by { |k| k[:count] }.reverse!
sorted_suggestions[0..4].each do |suggestion|
  puts "#{ suggestion[:name] } --- #{ suggestion[:count]}"
end
  
