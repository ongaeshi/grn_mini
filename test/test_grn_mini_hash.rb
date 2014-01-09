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
      hash["c"] = {text:"ccc", number:3}
      hash["a"] = {text:"aaa", number:1}
      hash["b"] = {text:"bbb", number:2}

      total = 0

      hash.each do |v|
        total += v.number
      end

      assert_equal 6, total
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

  def test_delete_by_id
    GrnMini::Hash.tmpdb do |hash|
      hash["a"] = {text:"aaa", number:1}
      hash["b"] = {text:"bbb", number:2}
      hash["c"] = {text:"ccc", number:3}

      # Delete from key
      assert_equal 3, hash.size
      assert_equal 2, hash["b"].number

      hash.delete("b")
      
      assert_equal 2, hash.size
      assert_nil hash["b"]
    end
  end

  def test_delete_by_block
    GrnMini::Hash.tmpdb do |hash|
      hash["a"] = {text:"aaa", number:1}
      hash["b"] = {text:"bbb", number:2}
      hash["c"] = {text:"ccc", number:3}

      hash.delete do |record|
        record.number >= 2
      end

      assert_equal 1, hash.size
      assert_equal "aaa", hash.first.text
      assert_equal 1, hash.first.number
    end
  end

  def test_float_column
    GrnMini::Hash.tmpdb do |hash| 
      hash["a"] = {text:"aaaa", float: 1.5}
      hash["b"] = {text:"bbbb", float: 2.5}
      hash["c"] = {text:"cccc", float: 3.5}

      assert_equal 2.5, hash["b"].float

      results = hash.select("float:>2.6")
      assert_equal 3.5, results.first.float
    end
  end

  def test_time_column
    GrnMini::Hash.tmpdb do |hash| 
      hash["a"] = {text:"aaaa", timestamp: Time.new(2013)} # 2013-01-01
      hash["b"] = {text:"bbbb", timestamp: Time.new(2014)} # 2014-01-01
      hash["c"] = {text:"cccc", timestamp: Time.new(2015)} # 2015-01-01

      assert_equal Time.new(2014), hash["b"].timestamp

      results = hash.select("timestamp:<=#{Time.new(2013,12).to_i}")
      assert_equal 1, results.size
      assert_equal Time.new(2013), results.first.timestamp
    end    
  end

  def test_record_attributes
    GrnMini::Hash.tmpdb do |hash| 
      hash["a"] = {text:"aaaa", int: 1}
      hash["b"] = {text:"bbbb", int: 2}
      hash["c"] = {text:"cccc", int: 3}

      assert_equal({"_id"=>1, "_key"=>"a", "int"=>1, "text"=>"aaaa"}, hash["a"].attributes)
      assert_equal({"_id"=>2, "_key"=>"b", "int"=>2, "text"=>"bbbb"}, hash["b"].attributes)
      assert_equal({"_id"=>3, "_key"=>"c", "int"=>3, "text"=>"cccc"}, hash["c"].attributes)
    end
  end

  def test_assign_long_text_to_short_text
    GrnMini::Hash.tmpdb do |hash| 
      hash["a"] = {filename:"a.txt"}
      hash["b"] = {filename:"a"*4095 + ".txt" } # Over 4095 byte (ShortText limit)

      results = hash.select("txt", default_column: "filename")
      assert_equal 2, results.size 
    end
  end

end
