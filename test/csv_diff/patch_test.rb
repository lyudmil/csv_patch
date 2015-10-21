require 'test_helper'
require 'csv_diff/patch'

class PatchTest < MiniTest::Unit::TestCase

  def setup
    @changes = {
      '4' => { 'ID' => 4, 'A' => 'a4', 'B' => 'b4' },
      '5' => { 'ID' => 5, 'A' => 'a5', 'C' => 'c5' },
      '9' => nil
    }

    @output_stream = StringIO.new

    @patch = CsvDiff::Patch.new(@changes, @output_stream)
  end

  def teardown
    @output_stream.close
  end

  def test_leaves_unaffected_lines_as_they_are
    @patch.replace_line('1,a1,b1')

    @output_stream.rewind
    assert_equal "1,a1,b1\n", @output_stream.gets
  end

  def test_updates_lines_for_which_there_are_changes
    @patch.replace_line('5,,')

    @output_stream.rewind
    assert_equal "5,a5,c5\n", @output_stream.gets
  end

  def test_updates_the_schema_as_it_processes_the_changes
    @patch.replace_line('4,,')
    @patch.replace_line('5,,')

    @output_stream.rewind
    assert_equal "4,a4,b4\n", @output_stream.gets
    assert_equal "5,a5,,c5\n", @output_stream.gets
  end

  def test_processes_deletions
    @patch.replace_line('9,a,b,c,d,e')

    @output_stream.rewind
    assert_equal nil, @output_stream.gets
  end

  def test_parses_csv_lines_correctly
    patch = CsvDiff::Patch.new({ '"Smith'  => { 'a' => 1, 'b' => 2 }}, @output_stream)

    patch.replace_line('"Smith, John",,')

    @output_stream.rewind
    assert_equal "\"Smith, John\",,\n", @output_stream.gets
  end

  def test_can_generate_new_lines
    @patch.add_new_lines

    @output_stream.rewind
    assert_equal "4,a4,b4\n", @output_stream.gets
    assert_equal "5,a5,,c5\n", @output_stream.gets
    assert_equal nil, @output_stream.gets
  end

  def test_does_not_generate_new_lines_for_applied_changes
    @patch.replace_line('5,,')

    @patch.add_new_lines

    @output_stream.rewind
    assert_equal "5,a5,c5\n", @output_stream.gets
    assert_equal "4,a4,,b4\n", @output_stream.gets
    assert_equal nil, @output_stream.gets
  end

end
