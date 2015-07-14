require 'open-uri'
require 'json'


artist_list = []
artist_count = 0
artist_name = "init"
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
    puts artist_name
    artist_list << artist_name
    artist_count += 1
  end
end

queries = artist_list

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
  percentage = ((suggestion[:count]/artist_count) * 100)
  puts "#{ suggestion[:name] } --- #{ percentage }%"
end

  
