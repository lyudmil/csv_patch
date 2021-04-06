require 'csv_patch/operation'

module CsvPatch

  class Revision < Operation

    def initialize changes, output_stream, id_column = nil
      @output_stream  = output_stream
      @changes        = changes
      @id_column      = id_column

      header_line([])
    end

    def header_line line
      return unless line

      @columns          = line
      @id_column_index  = @columns.find_index(@id_column)

      mark_all_columns_empty
    end

    def replace_line line
      emit replacement_line_for(line)
    end

    def add_new_lines
      @changes
        .values
        .reject { |change| change.nil? }
        .reject { |change| change[:applied] }
        .each do |addition|
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
      values.to_json
    end

    def remove_colums_with_data_from_empty_columns values
      @empty_columns.select! { |column| values[column].nil? }
    end

    def change_for row
      change = @changes[id_of(row)]
      return nil if change.nil?

      change[:applied] = true
      change.reject { |k, _| k == :applied }
    end

    def update_schema_to_reflect change
      @columns += change.keys
      @columns.uniq!
    end

    def id_of row
      return row.first if @id_column_index.nil?
      row[@id_column_index]
    end

  end
end
