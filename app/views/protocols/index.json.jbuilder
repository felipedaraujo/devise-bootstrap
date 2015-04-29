json.array!(@protocols) do |protocol|
  json.extract! protocol, :id, :name, :procedure, :source, :author
  json.url protocol_url(protocol, format: :json)
end
