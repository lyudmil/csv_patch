require 'test_helper'

class PatchTest < Minitest::Test

  def setup
    @original = StringIO.new
    @original.puts 'ID,A,B,C,D,E,F'
    @original.puts "1,\"a1\na1.1\",b1,,d1"
    @original.puts '2,,b2,,,e2'
    @original.puts '3,,,,,,f3'
    @original.rewind

    @result = StringIO.new
  end

  def teardown
    @original.close
    @result.close
  end

  def test_patches_correctly_when_rows_change
    changes = { '1' => { 'ID' => 1, 'A' => "a1\na1.1", 'B' => 'B1!', 'D' => 'd1' }}

    patch = CsvPatch::Patch.new input: @original, output: @result, changes: changes
    patch.apply

    @result.rewind
    assert_equal "ID,A,B,D,E,F\n", @result.gets
    assert_equal "1,\"a1\n", @result.gets
    assert_equal "a1.1\",B1!,d1,,\n", @result.gets
    assert_equal "2,,b2,,e2\n", @result.gets
    assert_equal "3,,,,,f3\n", @result.gets

    assert_equal true, @result.eof?
  end

  def test_patches_correctly_when_adding_rows
    changes = { '4' => { 'ID' => 4 }}

    patch = CsvPatch::Patch.new input: @original, output: @result, changes: changes
    patch.apply

    @result.rewind
    assert_equal "ID,A,B,D,E,F\n", @result.gets
    assert_equal "1,\"a1\n", @result.gets
    assert_equal "a1.1\",b1,d1\n", @result.gets
    assert_equal "2,,b2,,e2\n", @result.gets
    assert_equal "3,,,,,f3\n", @result.gets
    assert_equal "4,,,,,\n", @result.gets

    assert_equal true, @result.eof?
  end

  def test_patches_correctly_when_deleting_rows
    changes = { '1' => nil, '3' => nil }

    patch = CsvPatch::Patch.new input: @original, output: @result, changes: changes
    patch.apply

    @result.rewind
    assert_equal "ID,B,E\n", @result.gets
    assert_equal "2,b2,e2\n", @result.gets

    assert_equal true, @result.eof?
  end

end
