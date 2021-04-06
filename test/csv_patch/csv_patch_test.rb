require 'test_helper'

class CsvPatchTest < Minitest::Test

  def setup
    @input    = StringIO.new
    @output   = StringIO.new
    @changes  = StringIO.new

    @changes_repository = [
      { '1' => { 'a' => 1, 'b' => '2' }},
      { '2' => nil },
      { '3' => { 'c' => 3, 'd' => '4' }},
      { '4' => { 'e' => 5 }},
      { '5' => { 'f' => 6 }},
      { '6' => nil },
      { '7' => { 'g' => 7, 'h' => 8 }}
    ]
  end

  def teardown
    [@input, @output, @changes].each { |io| io.close }
  end

  def test_processes_the_changes_file_in_a_single_batch_if_the_batch_size_is_greater_than_the_number_of_changes
    patch = mock('patch')
    patch.expects(:apply).with().once
    CsvPatch::Patch
      .expects(:new)
      .with(changes: batch_including(@changes_repository), input: @input, output: @output, id_column: nil)
      .once
      .returns(patch)

    setup_changes_file_with @changes_repository
    CsvPatch.patch(input: @input, output: @output, changes: @changes, batch_size: 7)
  end

  def test_processes_the_changes_file_in_multiple_batches_if_the_batch_size_is_smaller_than_the_number_of_changes
    result_of_first_patch, result_of_second_patch, result_of_third_patch = StringIO.new, StringIO.new, StringIO.new
    Tempfile.expects(:new).with('csv_patch').times(3)
      .returns(result_of_first_patch, result_of_second_patch, result_of_third_patch)

    first_patch, second_patch, third_patch, fourth_patch = mock('first_patch'), mock('second_patch'), mock('third_patch'), mock('fourth_patch')

    first_patch.expects(:apply)
    CsvPatch::Patch.expects(:new)
      .with(changes: batch_including(@changes_repository.slice(0, 2)), input: @input, output: result_of_first_patch, id_column: nil)
      .once.returns(first_patch)

    second_patch.expects(:apply)
    CsvPatch::Patch.expects(:new)
      .with(changes: batch_including(@changes_repository.slice(2, 2)), input: result_of_first_patch, output: result_of_second_patch, id_column: nil)
      .once.returns(second_patch)

    third_patch.expects(:apply)
    CsvPatch::Patch.expects(:new)
      .with(changes: batch_including(@changes_repository.slice(4, 2)), input: result_of_second_patch, output: result_of_third_patch, id_column: nil)
      .once.returns(third_patch)

    fourth_patch.expects(:apply)
    CsvPatch::Patch.expects(:new)
      .with(changes: batch_including([@changes_repository.last]), input: result_of_third_patch, output: @output, id_column: nil)
      .once.returns(fourth_patch)

    setup_changes_file_with @changes_repository
    CsvPatch.patch input: @input, output: @output, changes: @changes, batch_size: 2

    assert_equal true, result_of_first_patch.closed?, 'Should close the result of the first patch'
    assert_equal true, result_of_second_patch.closed?, 'Should close the result of the second patch'
    assert_equal true, result_of_third_patch.closed?, 'Should close the result of the third patch'
    assert_equal false, @input.closed?, 'Should not close the original input'
    assert_equal false, @output.closed?, 'Should not close the original output'
  end

  def test_batch_size_defaults_to_500
    batch = mock('batch', each: nil)
    CsvPatch::StreamBatch.expects(:new).with(@changes, 500).returns(batch)

    CsvPatch.patch input: @input, output: @output, changes: @changes
  end

  private

  def expect_to_apply_patch_including changes
    patch = mock('patch')
    patch.expects(:apply)

    CsvPatch::Patch
      .expects(:new)
      .with(changes: batch_including(changes), input: @input, output: @output)
      .returns(patch)
  end

  def setup_changes_file_with changes
    changes.each { |change| @changes.puts change.to_json }
    @changes.rewind
  end

  def batch_including changes
    changes.inject({}) { |batch, change| batch.merge(change) }
  end

end
