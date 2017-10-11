require 'open-uri'
require 'json'
require 'parallel'
require 'fileutils'
require 'nokogiri'

puts "Loading Zoopla listing page with hardcoded options"

# Will first read the csv file and work out how many days to search with the ?added=${n}_days qs

url = "https://www.zoopla.co.uk/for-sale/property/white-city/?beds_min=2&price_max=325000&identifier=white-city&q=White%20City%2C%20London&is_auction=false&is_shared_ownership=false&is_retirement_home=false&search_source=for-sale&radius=10&include_sold=true&page_size=100&pn="

initialListing = Nokogiri::HTML(open(url + "1"))

pageNoSelector = '.paginate > a'
lastPageIndicator = initialListing.css(pageNoSelector)[-2]
totalPages = lastPageIndicator && lastPageIndicator.text || 1



# Now need to request all the pages to scrape the property ids


jsonString = test.read
json = JSON.parse(jsonString)
totalPages = json["total_pages"]
links = (1..totalPages).flat_map do |n|
  json = JSON.parse(open("https://www.kerboodle.com/api/courses/20529/contents/search?&page=#{n}&sort=&order=&query=&module=Resources&tags=&user=&parent=15464&type=&source=&used_as=&filter=&content_ids=", "Cookie" => "_gat=1; oup-cookie=1_7-3-2017; _ga=GA1.2.2054181403.1488727782; PRUM_EPISODES=s=1488923439025&r=https%3A//www.kerboodle.com/users/active_session; _session_id=925b92051ccb68cdb2cf014504027b67").read)
  Parallel.map(json["entries"], in_processes: 8) do |entry|
    { "name" => entry["name"].gsub("/", "OR") + ".#{entry['file_ext']}", "url" => entry["content_object_link"], "location" => "AQA GCSE Sciences (9–1)/" + entry["location"].gsub(" > ", "/")}
  end
end

Parallel.map(links, in_process: 8) do |link|
  puts "#{link['location']}"
  dirname = "#{link['location']}"
  puts dirname
  puts check = File.directory?(dirname) 
  if !check && !dirname.empty?
    FileUtils.mkdir_p(dirname)
  end
  filename = [link["location"], link['name']].join("/")
  f = File.open("#{filename}", 'wb') do |file|
    IO.copy_stream(open("https://www.kerboodle.com#{link['url']}", "Cookie" => "_gat=1; oup-cookie=1_7-3-2017; _ga=GA1.2.2054181403.1488727782; PRUM_EPISODES=s=1488923439025&r=https%3A//www.kerboodle.com/users/active_session; _session_id=925b92051ccb68cdb2cf014504027b67"), file)
  end
end

puts "#{links.count} files downloaded"

# val files = for(i <- 1 to totalPages) yield {
#   json = JSON.parse(open(s"?page=$i").read)
#   json["entries"].map{ js =>
#     ("www.kerboodle.com" + js["objectLink"],
#     js["Location"].replace(' > ', '\/')
#     js["name"]
#     )
#   }
# }.flatten
#
# files.foreach{file =>
#   content = open(file._1).readAllBytes
#   ensureDirectory(file._2)
#   saveFile(file._1 + " /" + name, content)
# }