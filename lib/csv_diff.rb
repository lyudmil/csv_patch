require 'csv_diff/patch'

module CsvDiff

  def self.patch options
    Patch.new(options).apply
  end

end
