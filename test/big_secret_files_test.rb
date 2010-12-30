require 'test/unit'
require 'mocha'
require 'big_secret_files'

#
# The setup: Making things act like we're running from a rails app.
#

class String
  # dumb string extension for testing
  # real lib uses active_support from rails
  def underscore
    self.gsub(/([A-Z])/, '_\1').sub(/^_/, '').downcase
  end
end

class MyModel
  extend BigSecretFiles::Attachable
  has_big_secret :document
  
  # Make it behave like an ActiveRecord model:
  RAILS_ROOT = File.dirname(__FILE__)
  ENV = { "RAILS_ENV" => "test" }
  attr_accessor :document_filename
  def id; 1; end
  def new_record?; false; end
  def document_filename?
    document_filename && !document_filename.empty?
  end
end

module BigSecretFiles::Attachable
  RAILS_ROOT = MyModel::RAILS_ROOT
  ENV = MyModel::ENV
end

#
# The tests:
#

class BigSecretFilesTest < Test::Unit::TestCase
  UploadedFile = Struct.new(:path, :original_filename)
  
  def setup
    @my_model = MyModel.new
    rails_root = File.expand_path(MyModel::RAILS_ROOT)
    @expected_dir = File.join(rails_root, 'data', 'test', 'my_model', '1', 'document')
    FileUtils.stubs(:mkdir_p)
    FileUtils.stubs(:mv)
  end
  
  def test_dir
    assert_equal @expected_dir, @my_model.document_dir
  end
  
  def test_dir_on_new_record
    @my_model.stubs(:new_record?).returns(true)
    assert_nil @my_model.document_dir
  end
  
  def test_path
    @my_model.document_filename = "filename"
    assert_equal File.join(@expected_dir, "filename"), @my_model.document_path
  end
  
  def test_path_on_new_record
    @my_model.document_filename = "filename"
    @my_model.stubs(:new_record?).returns(true)
    assert_nil @my_model.document_path
  end
  
  def test_path_without_filename
    @my_model.stubs(:document_filename?).returns(false)
    assert_nil @my_model.document_path
  end
  
  def test_assignment
    FileUtils.expects(:mkdir_p).with(@expected_dir)
    FileUtils.expects(:mv).with('path', File.join(@expected_dir, 'filename'))
    @my_model.document = UploadedFile.new('path', 'filename')
    assert_equal 'filename', @my_model.document_filename
  end
  
  def test_assignment_to_nil
    assert_nothing_raised { @my_model.document = nil }
    assert_nil @my_model.document_filename
  end
  
  def test_default_existance
    # original state is no document
    assert !@my_model.has_document?
  end
  
  def test_existance_with_just_filename
    # filename exists but file does not
    @my_model.document_filename = 'filename'
    assert !@my_model.has_document?
  end
  
  def test_existance_with_just_file
    # file exists but filename does not
    @my_model.document_filename = nil
    File.stubs(:exist?).returns(true)
    assert !@my_model.has_document?
  end
  
  def test_existance_with_filename_and_file
    # filename and file exists
    @my_model.document_filename = 'filename'
    File.stubs(:exist?).with(File.join(@expected_dir, 'filename')).returns(true)
    assert @my_model.has_document?
  end
  
  def test_read_file
    @my_model.document = UploadedFile.new('path', 'filename')
    File.stubs(:exist?).with(File.join(@expected_dir, 'filename')).returns(true)
    File.stubs(:read).with(File.join(@expected_dir, 'filename')).returns("content")
    assert_equal "content", @my_model.document
  end
  
  def test_read_nonexistant_file
    assert_nil @my_model.document
  end
end
