require 'open-uri'

desc "Use plos data to populate the protocol's table"
task :plos => :environment do
  current_page = 0
  
  loop do
    current_page += 1
    
    articles_ids = find_ids(current_page)
    
    articles_ids.map do |id|
      protocol = find_protocol(id)
      store_protocol(protocol['response']['docs'].first)
    end

    break if @total_pages == current_page
  end
end

def find_ids(current_page)
  puts "page #{current_page} loading"
  alm_url = "http://alm.plos.org/api/v5/articles"  
  response = JSON.load(open("#{alm_url}?page=#{current_page}"))
  @total_pages = response['total_pages']
  response['data'].map {|article| article['id'].gsub('doi/','')}
end

def find_protocol(plos_id)
  api_url = "http://api.plos.org/search"
  JSON.load(open("#{api_url}?wt=json&fl=id,title,alternate_title,author,materials_and_methods,journal&q=id:#{plos_id}"))
end

def store_protocol(record)
  unless record['materials_and_methods'].nil?
    Protocol.where(plos_id: record['id']).first_or_create do |protocol|
      protocol.title           = record['title']
      protocol.alternate_title = record['alternate_title']
      protocol.author          = record['author']
      protocol.journal         = record['journal']
      protocol.method          = record['materials_and_methods']
      puts "#{record['id']} created"
    end
  end
end
