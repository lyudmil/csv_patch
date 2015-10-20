require 'flexmock'
require 'minitest/unit'

class MiniTest::Unit::TestCase
  include FlexMock::TestCase
end

MiniTest::Unit.autorun
