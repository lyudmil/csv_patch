require 'csv_patch/stream_batch'
require 'csv_patch/patch'

module CsvPatch

  DEFAULT_BATCH_SIZE = 500

  def self.patch options
    result_of_last_patch = nil
    batches(options).each do |changes, last_batch|
      input = result_of_last_patch || options[:input]
      result_of_last_patch.close if result_of_last_patch
      output = target_for_next_patch options[:output], last_batch
      result_of_last_patch = apply_patch(input, output, changes)
    end
  end

  private

  def self.target_for_next_patch final_target, last_batch
    return final_target if last_batch
    Tempfile.new('csv_patch')
  end

  def self.batches options
    StreamBatch.new(options[:changes], options[:batch_size] || DEFAULT_BATCH_SIZE)
  end

  def self.apply_patch input, output, changes
    Patch.new(input: input, output: output, changes: changes).apply

    output.rewind
    output
  end

end
