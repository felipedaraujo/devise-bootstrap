require 'open-uri'
require 'csv'
require 'sanitize'

namespace :plos do

  task :methods, [:initial_page] => [:environment] do |t, args|

    current_page = args[:initial_page].to_i

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

  desc "Create CSV using Protocol's information"
  task :csv => [:environment] do
    CSV.open("protocols.csv", "wb") do |csv|
      attributes = ["Protocol's Name",
                    "Total Characters",
                    "Numbers",
                    "Percentage of Numbers",
                    "Views",
                    "Citations",
                    "Source"]

      csv <<  attributes

      Protocol.all.map do |protocol|
        paragraphs_by_subtitle(protocol.method).map do |subtitle, content|
          m = metric_paragraph(content)

          values = [subtitle,
                    m[:total_characters],
                    m[:numbers],
                    m[:percent_numbers],
                    protocol.metric.views,
                    protocol.metric.citations,
                    protocol.source]

          csv << values
          puts "#{subtitle} OK"
        end
      end
    end
  end

  def paragraphs_by_subtitle(method)
    hash = {}
    count = 0

    loop do
      if method[count].include?('<h3>')
        key = Sanitize.clean(method[count])

        loop do
          count += 1

          hash[key] = [hash[key], method[count]].join(" ")

          break if count >= method.size - 1 || method[count + 1].include?('<h3>')
        end
      end
      count += 1
      break if count >= method.size - 1
    end
    hash
  end

  def numbers_in(paragraph)
    numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
    times = 0

    numbers.map { |n| times += paragraph.count(n) }

    times
  end

  def metric_paragraph(content)
    sanitized_content = Sanitize.clean(content)

    total_characters = sanitized_content.size

    numbers = numbers_in(sanitized_content)

    percent_numbers = (( numbers.to_f * 100 ) / total_characters ).round(2)

    { total_characters: total_characters, numbers: numbers, percent_numbers: percent_numbers}
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

      journal = url.split('/')[2..3].join('/')

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
      protocol.source          = record['url']
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