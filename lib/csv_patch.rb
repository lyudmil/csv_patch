require 'csv_patch/patch'

module CsvPatch

  def self.patch options
    Patch.new(options).apply
  end

end
