require 'open-uri'

namespace :plos do

  task :pathogens => :environment do
    # Skiping data stored on the API that is not from PLOS
    current_page = 0
    section_name = "Materials and Methods"

    loop do
      current_page += 1
      
      articles_seeds = seeds(current_page)

      if articles_seeds.any?
        articles_seeds.each do |seed|
          attributes = get_attrs(seed['url'], section_name)

          unless attributes.nil?
              seed.merge!('author'  => attributes[:primary_author],
                          'section' => attributes[:section],
                          'journal' => attributes[:journal])

            create(seed)
          end
        end
      end
      
      break if @total_pages == current_page
    end
  end

  def seeds(current_page)
    puts "page #{current_page} loading"
    
    alm_url = "http://alm.plos.org/api/v5/articles"  
    response = JSON.load(open("#{alm_url}?page=#{current_page}"))
    
    @total_pages = response['total_pages']
    
    response['data'].delete_if { |article| article['doi'].nil? || article['url'].nil? }
  end

  def find_protocol
    api_url = "http://api.plos.org/search"
    
    record = JSON.load(open("#{api_url}?wt=json&fl=id,title,alternate_title,author,materials_and_methods,journal&q=id:#{seed_id}"))
    record['response']['docs']
  end

  def get_attrs(url, name)
    page = Nokogiri::HTML(open(url)){ |config| config.noblanks }

    unless page.at("a[title='#{name}']").nil?
      authors = page.xpath("//ul[@id='author-list']//li")
      
      section_title = page.at_xpath("//h2[contains(., '#{name}')]")
      section = get_section(section_title)

      journal = url.split('/')[3] 

      response = { primary_author: primary_author(authors), section: section, journal: journal}
    end
  end

  def primary_author(authors)
    author_tag = authors.first.at("a[class='author-name']")
    primary_author = author_tag.text.gsub(',', '').strip
  end

  def get_section(title)  
    nodeset = title.parent.children
    
    section = nodeset.map do |node|
      unless node.nil? || ['a', 'text', 'h2'].include?(node.name) 
        node
      end
    end
    section.compact
  end
  
  def create(record)
    Protocol.where(plos_id: record['doi']).first_or_create do |protocol|
      protocol.title           = record['title']
      protocol.author          = record['author']
      protocol.journal         = record['journal']
      protocol.method          = record['section']
      
      metric = Metric.new(views: record['viewed'], citations: record['cited'])
      protocol.metric = metric
      
      puts "#{record['doi']} created"
    end
  end
  
  # desc "Use plos data to populate the protocol's table"
  # task :all => :environment do
  #   current_page = 0
    
  #   loop do
  #     current_page += 1
      
  #     articles_seeds = seeds(current_page, "")
      
  #     articles_seeds.map do |seed|
  #       @seed = seed
  #       protocol = find_protocol
  #       store_protocol(protocol.first) if protocol.any?
  #     end

  #     break if @total_pages == current_page
  #   end
  # end

  # def seed_id
  #   @seed['doi']
  # end

  # def seed_views
  #   @seed['viewed']
  # end

  # def seed_citations
  #   @seed['cited']
  # end

  # def store_metric(protocol)
  #   metric = Metric.create(views: seed_views, citations: seed_citations)
  #   protocol.metric = metric
  # end
  
  # def store_protocol(record)
  #   unless record['materials_and_methods'].nil?
  #     Protocol.where(plos_id: record['id']).first_or_create do |protocol|
  #       protocol.title           = record['title']
  #       protocol.alternate_title = record['alternate_title'].first
  #       protocol.author          = record['author'].join(', ')
  #       protocol.journal         = record['journal']
  #       protocol.method          = record['materials_and_methods'].first
  #       puts "#{record['id']} created"
        
  #       store_metric(protocol)
  #     end
  #   end
  # end
end