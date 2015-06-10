require 'open-uri'
require 'json'

puts "What track would you like to search for?"
query = gets
path = "https://api.spotify.com/v1/search?type=track&q=" + query
results = JSON.parse(open(path).read)
tracks = results.fetch("tracks").fetch("items")

tracks.each do |track|
  artists = track.fetch("artists")
  artist_list = []
  artists.each do |artist|
    artist_name = artist.fetch("name")
    artist_list << artist_name
  end
  presentable_artists = ""
  if artist_list.size == 1
    presentable_artists = artist_list[0]
  else
    artist_list.each do |artist|
      presentable_artists = presentable_artists + artist + " "
    end
  end
  puts track.fetch("name") + " by " + presentable_artists
end

