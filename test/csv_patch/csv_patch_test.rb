require 'test_helper'

class CsvPatchTest < MiniTest::Unit::TestCase

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
    setup_changes_file_with @changes_repository.slice(0, 3)

    expect_to_apply_patch_including @changes_repository.slice(0, 3)

    @changes.rewind
    CsvPatch.patch input: @input, output: @output, changes: @changes, batch_size: 4
  end

  def test_processes_the_changes_file_in_multiple_batches_if_the_batch_size_is_smaller_than_the_number_of_changes
    setup_changes_file_with @changes_repository

    expect_to_apply_patch_including @changes_repository.slice(0, 2)
    expect_to_apply_patch_including @changes_repository.slice(2, 2)
    expect_to_apply_patch_including @changes_repository.slice(4, 2)
    expect_to_apply_patch_including [@changes_repository.last]

    @changes.rewind
    CsvPatch.patch input: @input, output: @output, changes: @changes, batch_size: 2
  end

  def test_batch_size_defaults_to_500
    changes = []
    501.times { |i| changes.push({ i.to_s => nil }) }

    setup_changes_file_with changes

    expect_to_apply_patch_including changes.slice(0, 500)
    expect_to_apply_patch_including [changes.last]

    @changes.rewind
    CsvPatch.patch output: @output, input: @input, changes: @changes
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
  end

  def batch_including changes
    changes.inject({}) { |batch, change| batch.merge(change) }
  end

end
