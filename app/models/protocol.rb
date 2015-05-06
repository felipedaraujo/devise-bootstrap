class Protocol < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ['title^10', 'method']
          }
        }
      }
    )
  end

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :title, analyzer: 'english'
      indexes :method, analyzer: 'english'
    end
  end
end
Protocol.__elasticsearch__.client.indices.delete index: Protocol.index_name rescue nil
 
Protocol.__elasticsearch__.client.indices.create \
  index: Protocol.index_name,
  body: { settings: Protocol.settings.to_hash, mappings: Protocol.mappings.to_hash }
 
Protocol.import
