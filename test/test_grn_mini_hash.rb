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

  def test_select
    GrnMini::Hash.tmpdb do |hash|
      hash["a"] = {text:"aaa", number:1}
      hash["b"] = {text:"bbb", number:2}
      hash["c"] = {text:"ccc", number:3}

      results = hash.select("bb")

      assert_equal 1, results.size
      assert_equal "b", results.first.key.key
      assert_equal "bbb", results.first.text
    end 
  end

  def test_select2
    GrnMini::Hash.tmpdb do |hash|
      hash["a"] = {text:"aaa", number:1}
      hash["b"] = {text:"bbb", number:2}
      hash["c"] = {text:"bbb", number:20}
      hash["d"] = {text:"ccc", number:3}

      results = hash.select("bb number:<10")

      assert_equal 1, results.size
      assert_equal "b", results.first.key.key
      assert_equal "bbb", results.first.text
      assert_equal 2, results.first.number
    end 
  end

end
