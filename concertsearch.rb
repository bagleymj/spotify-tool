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
    artist_list << artist_name
    artist_count += 1
  end
end

queries = artist_list

#Calculate!
suggestions = []
queries.each do |query|
  path = "http://developer.echonest.com/api/v4/artist/similar?api_key=7B2DCIZJX0PVRLNXJ&name=#{ query }&format=json&start=0"
  results = JSON.parse(open(path).read)
  artists = results.fetch("response").fetch("artists")
  artists.each do |artist|
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

  
