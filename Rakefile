# encoding: utf-8

require 'jeweler'
require 'rake/testtask'
require 'rdoc/task'

Jeweler::Tasks.new do |gem|
  gem.name = 'csv_diff'
  gem.summary = %Q{Apply diffs to a CSV file}
  gem.description = %Q{Applies a list of changes in a given format to a CSV file}
  gem.email = 'lyudmilangelov@gmail.com'
  gem.authors = ['Lyudmil']
  gem.files.exclude 'test/**/*', '.*'
end

Rake::TestTask.new(:test) do |test|
 test.libs << 'lib' << 'test'
 test.pattern = 'test/**/*_test.rb'
 test.verbose = true
end

Rake::RDocTask.new do |rdoc|
 version = File.exist?('VERSION') ? File.read('VERSION') : ''

 rdoc.rdoc_dir = 'rdoc'
 rdoc.title = 'csv_diff #{version}'
 rdoc.rdoc_files.include('README*')
 rdoc.rdoc_files.include('lib/**/*.rb')
end
