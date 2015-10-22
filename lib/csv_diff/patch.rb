require 'tempfile'
require 'csv_diff/revision'
require 'csv_diff/compression'

module CsvDiff

  class Patch

    TEMPFILE_NAME = 'csv_patch'

    def initialize options
      @input, @output   = options[:input], options[:output]

      @revision_result  = Tempfile.new(TEMPFILE_NAME)
      @revision         = Revision.new(options[:changes], @revision_result)
    end

    def apply
      apply_changes
      compress
    end

    private

    def apply_changes
      @revision.header_line(@input.gets)
      @revision.replace_line(@input.gets) until @input.eof?
      @revision.add_new_lines
    end

    def compress
      @revision_result.rewind

      compression.execute

      @revision_result.close
    end

    def compression
      Compression.new(@revision_result, @output, @revision.column_metadata)
    end

  end
end
