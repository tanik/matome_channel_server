module BoardSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_commit :create_index, on: :create
    after_commit :update_index, on: :update
    after_destroy :destroy_index

    index_name "boards-#{Rails.env}"

    settings index: {
      number_of_shards:   1,
      number_of_replicas: 0,
      analysis: {
        filter: {
          greek_lowercase_filter: {
            type:     'lowercase',
            language: 'greek',
          },
        },
        tokenizer: {
          kuromoji: {
            type: 'kuromoji_tokenizer'
          },
        },
        analyzer: {
          kuromoji_analyzer: {
            type:      'custom',
            tokenizer: 'kuromoji_tokenizer',
            filter:    ['kuromoji_baseform', 'kuromoji_part_of_speech', 'greek_lowercase_filter', 'cjk_width'],
          }
        }
      }
    } do
      mapping dynamic: 'false' do
        indexes :id, type: 'integer', index: 'not_analyzed'
        indexes :title, type: 'string', index: 'analyzed', analyzer: 'kuromoji_analyzer'
        indexes :category do
          indexes :name, type: "string", analyzer: "kuromoji_analyzer"
        end
        indexes :comments do
          indexes :content, type: "string", analyzer: "kuromoji_analyzer"
        end
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

    private
    def create_index
      BoardIndexer.perform_async('create', self.id)
    end

    def update_index
      BoardIndexer.perform_async('update', self.id)
    end

    def destroy_index
      # not async
      self.__elasticsearch__.delete_document
    end
  end

  module ClassMethods
    def create_index!(options={})
      client = __elasticsearch__.client
      client.indices.delete index: index_name rescue nil if options[:force]
      client.indices.create index: index_name, body: {
        settings: settings.to_hash,
        mappings: mappings.to_hash
      }
    end
  end
end
