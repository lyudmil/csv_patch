require 'test_helper'

class CompressionTest < MiniTest::Unit::TestCase

  def setup
    @input_stream   = StringIO.new
    @output_stream  = StringIO.new
  end

  def teardown
    @input_stream.close
    @output_stream.close
  end

  def test_removes_empty_columns
    @input_stream.puts ['a1', 'b1', nil, 'd1'].to_json
    @input_stream.puts ['a2', 'b2'].to_json
    @input_stream.puts [nil,nil,nil,nil,nil,'f3'].to_json
    @input_stream.rewind

    column_metadata = { columns: ['A', 'B', 'C', 'D', 'E', 'F'], empty_columns: [2, 4] }
    @compression = CsvPatch::Compression.new(@input_stream, @output_stream, column_metadata)

    @compression.execute

    @output_stream.rewind
    assert_equal "A,B,D,F\n", @output_stream.gets
    assert_equal "a1,b1,d1\n", @output_stream.gets
    assert_equal "a2,b2\n", @output_stream.gets
    assert_equal ",,,f3\n", @output_stream.gets

    assert_equal true, @input_stream.eof?
  end

  def test_handles_records_that_span_several_lines
    @input_stream.puts ["a1\na1.1", 'b1', nil, 'd1'].to_json
    @input_stream.rewind

    @compression = CsvPatch::Compression.new(@input_stream, @output_stream, columns: ['A', 'B', 'C', 'D'], empty_columns: [2])

    @compression.execute

    @output_stream.rewind
    assert_equal "A,B,D\n", @output_stream.gets
    assert_equal "\"a1\n", @output_stream.gets
    assert_equal "a1.1\",b1,d1\n", @output_stream.gets
  end

end
