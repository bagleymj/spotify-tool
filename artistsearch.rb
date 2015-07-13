require 'open-uri'
require 'json'

puts "Which artist would you like to search for?"
query = gets
path = "http://developer.echonest.com/api/v4/artist/similar?api_key=7B2DCIZJX0PVRLNXJ&name=" + query + "&format=JSON&&start=0"
results = JSON.parse(open(path).read)
artists = results.fetch("response").fetch("artists")
artists.each do |artist|
  name = artist.fetch("name")
  puts name
end
