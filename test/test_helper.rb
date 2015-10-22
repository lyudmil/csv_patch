require 'flexmock'
require 'minitest/unit'

require 'csv_diff'

class MiniTest::Unit::TestCase
  include FlexMock::TestCase
end

MiniTest::Unit.autorun
