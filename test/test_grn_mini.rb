require 'minitest_helper'
require 'fileutils'

class TestGrnMini < MiniTest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GrnMini::VERSION
  end

  def test_tmpdb
    GrnMini::tmpdb do
      array = GrnMini::Array.new
    end
  end

  def test_tmpdb_block_isnt_given
    dir = GrnMini::tmpdb

    array = GrnMini::Array.new

    FileUtils.remove_entry_secure dir
  end

  def test_default_tokenizer
    prev = GrnMini::default_tokenizer
    GrnMini::default_tokenizer = "TokenBigramIgnoreBlank"
    assert_equal "TokenBigramIgnoreBlank", GrnMini::default_tokenizer

    GrnMini::tmpdb do
      array = GrnMini::Array.new
    end

    GrnMini::default_tokenizer = prev
  end
end
