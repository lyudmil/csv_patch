require 'csv_patch/batches'

module CsvPatch

  def self.patch options
    Batches.new(options).execute
  end

end
