require 'flexmock'
require 'minitest/unit'

require 'csv_patch'

class MiniTest::Unit::TestCase
  include FlexMock::TestCase
end

MiniTest::Unit.autorun
