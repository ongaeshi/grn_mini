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

  def test_size
    GrnMini::Hash.tmpdb do |hash|
      assert_equal 0, hash.size
      assert_equal 0, hash.length
      
      hash["a"] = {text:"aaa", number:1}
      hash["b"] = {text:"bbb", number:2}
      assert_equal 2, hash.size
      assert_equal 2, hash.length
    end
  end

  def test_empty?
    GrnMini::Hash.tmpdb do |hash|
      assert_equal true, hash.empty?

      hash["a"] = {text:"aaa", number:1}
      assert_equal false, hash.empty?
    end
  end

  def test_each
    GrnMini::Hash.tmpdb do |hash|
      hash["a"] = {text:"aaa", number:1}
      hash["b"] = {text:"bbb", number:2}
      hash["c"] = {text:"ccc", number:3}

      hash.each_with_index do |v, index|
        case index
        when 0
          assert_equal "aaa", v.text
          assert_equal 1, v.number
        when 1
          assert_equal "bbb", v.text
          assert_equal 2, v.number
        when 2
          assert_equal "ccc", v.text
          assert_equal 3, v.number
        end
      end
    end
  end

  def test_read_by_key
    GrnMini::Hash.tmpdb do |hash|
      hash["a"] = {text:"aaa", number:1}
      hash["b"] = {text:"bbb", number:2}
      hash["c"] = {text:"ccc", number:3}

      assert_equal   nil, hash["not found"]
      assert_equal "aaa", hash["a"].text
      assert_equal "bbb", hash["b"].text
      assert_equal "ccc", hash["c"].text
    end
  end

  def test_write_by_key
    GrnMini::Hash.tmpdb do |hash|
      hash["a"] = {text:"aaa", number:1}
      hash["b"] = {text:"bbb", number:2}
      hash["c"] = {text:"ccc", number:3}

      assert_equal "bbb", hash["b"].text
      assert_equal     2, hash["b"].number

      hash["b"].text   = "BBB"
      hash["b"].number = 22

      assert_equal "BBB", hash["b"].text
      assert_equal    22, hash["b"].number
    end
  end

end
