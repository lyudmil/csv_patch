require 'json'
require 'ostruct'

module CsvPatch

  class StreamBatch

    def initialize stream, batch_size
      @stream     = stream
      @batch_size = batch_size
    end

    def each
      yield next_batch until stream_end?
    end

    private

    def next_batch
      OpenStruct.new(changes: next_batch_of_changes, last?: stream_end?)
    end

    def next_batch_of_changes
      batch = {}

      batch.merge!(next_change) until batch_full?(batch)

      batch
    end

    def next_change
      JSON.parse(@stream.gets)
    end

    def batch_full? batch
      batch.size >= @batch_size || stream_end?
    end

    def stream_end?
      @stream.eof?
    end

  end
end
