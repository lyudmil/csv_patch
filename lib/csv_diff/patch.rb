require 'csv'

module CsvDiff
  class Patch

    def initialize changes, output_stream
      @output_stream  = output_stream
      @changes        = changes
      @columns        = []
    end

    def replace_line line
      CSV.parse(line) do |row|
        emit replacement_line_for(row)
      end
    end

    def add_new_lines
      @changes.values.each do |addition|
        emit generate_new_row(addition)
      end
    end

    private

    def emit line
      return if line.nil?
      @output_stream.puts line
    end

    def changed? row
      @changes.has_key? id_of(row)
    end

    def replacement_line_for row
      return csv_line(row) unless changed?(row)
      generate_new_row change_for(row)
    end

    def generate_new_row row_data
      return if row_data.nil?

      update_schema_to_reflect row_data
      line_for row_data
    end

    def line_for change
      values = @columns.collect { |column| change[column] }
      csv_line(values)
    end

    def csv_line values
      CSV.generate_line(values)
    end

    def change_for row
      @changes.delete id_of(row)
    end

    def update_schema_to_reflect change
      @columns += change.keys
      @columns.uniq!
    end

    def id_of row
      row.first
    end

  end
end
