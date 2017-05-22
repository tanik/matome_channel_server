module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: {
      number_of_shards:   1,
      number_of_replicas: 0,
    } do
      mapping do
      end
    end

    def as_indexed_json(options={})
      self.as_json(
        only: [:id, :title],
        include: {
          category: {
            only: :name
          },
          comments: {
            only: :content
          },
        }
      )
    end

    #def self.search(query)
    #end
  end

  module ClassMethods
    def create_index!(options={})
      client = __elasticsearch__.client
      client.indices.delete index: "matome_channel" rescue nil if options[:force]
      client.indices.create index: "matome_channel", body: {
        settings: settings.to_hash,
        mappings: mappings.to_hash
      }
    end
  end
end
