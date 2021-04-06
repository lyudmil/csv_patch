require 'csv_patch/stream_batch'
require 'csv_patch/patch'

module CsvPatch

  class Batches

    DEFAULT_BATCH_SIZE = 500

    def initialize options
      @intermediate_files = []
      @input, @output     = options[:input], options[:output]
      @batches            = StreamBatch.new(options[:changes], options[:batch_size] || DEFAULT_BATCH_SIZE)
      @id_column          = options[:id_column]
    end

    def execute
      apply_changes_in_batches
      close_intermediate_files
    end

    private

    def apply_changes_in_batches
      @batches.each { |batch| patch_for(batch).apply }
    end

    def patch_for batch
      Patch.new(patch_options(batch))
    end

    def patch_options batch
      {
        input: input_for_next_patch,
        output: output_for_next_patch(batch),
        changes: batch.changes,
        id_column: @id_column
      }
    end

    def close_intermediate_files
      @intermediate_files.each(&:close)
    end

    def input_for_next_patch
      last_intermediate_file || @input
    end

    def last_intermediate_file
      return if @intermediate_files.empty?

      @intermediate_files.last.rewind
      @intermediate_files.last
    end

    def output_for_next_patch batch
      return @output if batch.last?
      new_intermediate_file
    end

    def new_intermediate_file
      @intermediate_files << Tempfile.new('csv_patch')
      @intermediate_files.last
    end

  end

end
