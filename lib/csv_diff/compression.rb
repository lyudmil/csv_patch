require 'csv_diff/operation'

module CsvDiff

  class Compression < Operation

    def initialize input_stream, output_stream, column_metadata
      @empty_columns  = column_metadata[:empty_columns]
      @headers        = column_metadata[:columns]

      @input_stream   = input_stream
      @output_stream  = output_stream
    end

    def execute
      emit_header_row
      emit_compressed_data
    end

    private

    def emit_header_row
      emit remove_empty_columns_from(@headers)
    end

    def emit_compressed_data
      emit compress(@input_stream.gets) until @input_stream.eof?
    end

    def emit row
      @output_stream.puts csv_line(row)
    end

    def compress line
      remove_empty_columns_from csv_values(line)
    end

    def remove_empty_columns_from row
      row.reject.with_index { |value, index| @empty_columns.include?(index) }
    end

  end

end
