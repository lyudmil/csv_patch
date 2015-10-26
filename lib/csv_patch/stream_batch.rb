require 'json'

class StreamBatch

  def initialize stream, batch_size
    @stream = stream
    @batch_size = batch_size
  end

  def each
    yield next_batch until stream_end?
  end

  private

  def next_batch
    change_batch = {}

    change_batch.merge! next_change until batch_full?(change_batch)

    change_batch
  end

  def next_change
    JSON.parse(@stream.gets)
  end

  def batch_full? change_batch
    change_batch.keys.size >= @batch_size || stream_end?
  end

  def stream_end?
    @stream.eof?
  end

end
