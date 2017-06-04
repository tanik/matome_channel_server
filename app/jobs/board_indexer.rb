class BoardIndexer
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 5

  def perform(operation, id)
    board = Board.find(id) rescue nil
    return if board.nil?
    case operation.to_s
    when 'create'
      board.__elasticsearch__.index_document
    when 'update'
      board.__elasticsearch__.update_document
    else
      raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end
