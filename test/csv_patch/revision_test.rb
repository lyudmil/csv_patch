require 'test_helper'

class RevisionTest < MiniTest::Unit::TestCase

  def setup
    @changes = {
      '4' => { 'ID' => 4, 'A' => 'a4', 'B' => 'b4' },
      '5' => { 'ID' => 5, 'A' => 'a5', 'C' => 'c5' },
      '9' => nil
    }

    @output_stream = StringIO.new

    @revision = CsvPatch::Revision.new(@changes, @output_stream)
  end

  def teardown
    @output_stream.close
  end

  def test_processes_header_lines_correctly
    @revision.header_line('ID,Name,B')

    assert_equal ['ID', 'Name', 'B'], @revision.column_metadata[:columns]

    @output_stream.rewind
    assert_equal true, @output_stream.eof?, 'Header line should not write to output stream'

    @revision.replace_line('4,,,')

    @output_stream.rewind
    assert_equal "[4,null,\"b4\",\"a4\"]\n", @output_stream.gets, 'Header line should have changed the schema'
    assert_equal true, @output_stream.eof?
  end

  def test_processes_blank_header_lines
    @revision.header_line(nil)

    assert_equal [], @revision.column_metadata[:columns]
  end

  def test_leaves_unaffected_lines_as_they_are
    @revision.replace_line('1,a1,b1')

    @output_stream.rewind
    assert_equal "[\"1\",\"a1\",\"b1\"]\n", @output_stream.gets
  end

  def test_updates_lines_for_which_there_are_changes
    @revision.replace_line('5,,')

    @output_stream.rewind
    assert_equal "[5,\"a5\",\"c5\"]\n", @output_stream.gets
  end

  def test_updates_the_schema_as_it_processes_the_changes
    @revision.replace_line('4,,')
    @revision.replace_line('5,,')

    @output_stream.rewind
    assert_equal "[4,\"a4\",\"b4\"]\n", @output_stream.gets
    assert_equal "[5,\"a5\",null,\"c5\"]\n", @output_stream.gets
  end

  def test_processes_deletions
    @revision.replace_line('9,a,b,c,d,e')

    @output_stream.rewind
    assert_equal nil, @output_stream.gets
  end

  def test_parses_csv_lines_correctly
    revision = CsvPatch::Revision.new({ '"Smith'  => { 'a' => 1, 'b' => 2 }}, @output_stream)

    revision.replace_line('"Smith, John",,')

    @output_stream.rewind
    assert_equal "[\"Smith, John\",null,null]\n", @output_stream.gets
  end

  def test_can_generate_new_lines
    @revision.add_new_lines

    @output_stream.rewind
    assert_equal "[4,\"a4\",\"b4\"]\n", @output_stream.gets
    assert_equal "[5,\"a5\",null,\"c5\"]\n", @output_stream.gets
    assert_equal true, @output_stream.eof?
  end

  def test_does_not_generate_new_lines_for_applied_changes
    @revision.replace_line('5,,')

    @revision.add_new_lines

    @output_stream.rewind
    assert_equal "[5,\"a5\",\"c5\"]\n", @output_stream.gets
    assert_equal "[4,\"a4\",null,\"b4\"]\n", @output_stream.gets
    assert_equal true, @output_stream.eof?
  end

  def test_keeps_track_of_empty_columns_in_the_column_metadata
    @revision.header_line('A,B,C,D')

    assert_equal [0, 1, 2, 3], @revision.column_metadata[:empty_columns], 'All columns initially empty'

    @revision.replace_line 'a,,,'

    assert_equal [1, 2, 3], @revision.column_metadata[:empty_columns], 'After adding data in the first column'

    @revision.replace_line ',,c,'

    assert_equal [1, 3], @revision.column_metadata[:empty_columns], 'After reading boolean data in the third column'

    @revision.replace_line ',b,,d'

    assert_equal [], @revision.column_metadata[:empty_columns], 'After reading data into columns 2 and 4'
  end

  def test_accounts_for_booleans_appropriately_when_determining_empty_columns
    changes = { '1' => { 'ID' => 1, 'A' => true, 'C' => false }}
    revision = CsvPatch::Revision.new(changes, @output_stream)

    revision.header_line('ID,A,B,C')

    revision.replace_line('2,,false,')

    assert_equal [1, 3], revision.column_metadata[:empty_columns], 'After processing unchanged line'

    revision.replace_line('1,')

    assert_equal [], revision.column_metadata[:empty_columns], 'After processing a change with booleans'

    @output_stream.rewind
    assert_equal "[\"2\",null,\"false\",null]\n", @output_stream.gets
    assert_equal "[1,true,null,false]\n", @output_stream.gets
    assert_equal true, @output_stream.eof?
  end

end
