require 'minitest_helper'

class TestGrnMiniHash < MiniTest::Unit::TestCase
  def test_initialize
    Dir.mktmpdir do |dir|
      hash = GrnMini::Hash.new(File.join(dir, "test.db"))
    end
  end

  def test_add
    GrnMini::Hash.tmpdb do |hash|
      hash.add("aaa", text:"aaa", number:1)
      assert_equal 1, hash.size

      # alias []=
      hash["bbb"] = {text:"bbb", number:2}
      assert_equal 2, hash.size
    end 
  end

end
