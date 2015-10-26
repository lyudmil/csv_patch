require 'csv_patch/stream_batch'
require 'csv_patch/patch'

module CsvPatch

  def self.patch options
    batches(options).each { |changes| apply_patch(options, changes) }
  end

  private

  def self.batches options
    StreamBatch.new(options[:changes], options[:batch_size])
  end

  def self.apply_patch options, changes
    Patch.new(input: options[:input], output: options[:output], changes: changes).apply
  end

end
