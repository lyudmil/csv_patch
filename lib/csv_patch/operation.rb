require 'csv'

module CsvPatch
  class Operation

    def csv_values line_of_csv
      CSV.parse_line(line_of_csv)
    end

    def csv_line values
      CSV.generate_line(values)
    end

  end
end
