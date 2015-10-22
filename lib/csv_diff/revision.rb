module CsvDiff
  class Revision < Operation

    EMPTY_LINE = "\n"

    def initialize changes, output_stream
      @output_stream  = output_stream
      @changes        = changes

      header_line(EMPTY_LINE)
    end

    def header_line line
      @columns = csv_values(line)
      mark_all_columns_empty
    end

    def replace_line line
      emit replacement_line_for csv_values(line)
    end

    def add_new_lines
      @changes.values.each do |addition|
        emit generate_new_row(addition)
      end
    end

    def column_metadata
      { columns: @columns, empty_columns: @empty_columns }
    end

    private

    def mark_all_columns_empty
      @empty_columns = (0..@columns.size - 1).to_a
    end

    def emit line
      return if line.nil?
      @output_stream.puts line
    end

    def changed? row
      @changes.has_key? id_of(row)
    end

    def replacement_line_for row
      return create_output_line_from(row) unless changed?(row)
      generate_new_row change_for(row)
    end

    def generate_new_row row_data
      return if row_data.nil?

      update_schema_to_reflect row_data
      line_for row_data
    end

    def line_for change
      values = @columns.collect { |column| change[column] }
      create_output_line_from(values)
    end

    def create_output_line_from values
      remove_colums_with_data_from_empty_columns(values)
      csv_line(values)
    end

    def remove_colums_with_data_from_empty_columns values
      @empty_columns.select! { |column| values[column].nil? }
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
