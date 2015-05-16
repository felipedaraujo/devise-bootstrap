module ProtocolsHelper
  # def shorten_method(text, link)
  #   simple_format(truncate(text, length: 460, omission: '... ', separator: ' ') +
  #                 link_to('read more', link))
  # end

  def paragraphs_by_subtitle(method)
    hash = {}
    count = 0

    loop do
      if method[count].include?('<h3>')
        key = strip_tags(method[count])

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
    total_characters = strip_tags(content).size
    
    numbers = numbers_in(content)

    puts total_characters.class
    puts numbers.class

    percent_numbers = (( numbers.to_f * 100 ) / total_characters ).round(2)

    "<strong>#{total_characters}</strong> total characters - <strong>#{numbers}</strong> numbers (<strong>#{percent_numbers}</strong>% of total)"
  end
end
