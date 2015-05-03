module ProtocolsHelper
  def shorten_method(text, link)
    simple_format(truncate(text, length: 460, omission: '... ', separator: ' ') +
                  link_to('read more', link))
  end
end
