require 'minitest_helper'

class TestGrnMiniHash < MiniTest::Unit::TestCase
  def test_initialize
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new
    end
  end

  def test_add
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

      hash.add("aaa", text:"aaa", number:1)
      assert_equal 1, hash.size

      # alias []=
      hash["bbb"] = {text:"bbb", number:2}
      assert_equal 2, hash.size
    end 
  end

  def test_select
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

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
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

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
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

      assert_equal 0, hash.size
      assert_equal 0, hash.length
      
      hash["a"] = {text:"aaa", number:1}
      hash["b"] = {text:"bbb", number:2}
      assert_equal 2, hash.size
      assert_equal 2, hash.length
    end
  end

  def test_empty?
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

      assert_equal true, hash.empty?

      hash["a"] = {text:"aaa", number:1}
      assert_equal false, hash.empty?
    end
  end

  def test_each
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

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
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

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
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

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
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

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
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

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
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

      hash["a"] = {text:"aaaa", float: 1.5}
      hash["b"] = {text:"bbbb", float: 2.5}
      hash["c"] = {text:"cccc", float: 3.5}

      assert_equal 2.5, hash["b"].float

      results = hash.select("float:>2.6")
      assert_equal 3.5, results.first.float
    end
  end

  def test_time_column
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

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
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

      hash["a"] = {text:"aaaa", int: 1}
      hash["b"] = {text:"bbbb", int: 2}
      hash["c"] = {text:"cccc", int: 3}

      assert_equal({"_id"=>1, "_key"=>"a", "int"=>1, "text"=>"aaaa"}, hash["a"].attributes)
      assert_equal({"_id"=>2, "_key"=>"b", "int"=>2, "text"=>"bbbb"}, hash["b"].attributes)
      assert_equal({"_id"=>3, "_key"=>"c", "int"=>3, "text"=>"cccc"}, hash["c"].attributes)
    end
  end

  def test_assign_long_text_to_short_text
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

      hash["a"] = {filename:"a.txt"}
      hash["b"] = {filename:"a"*4095 + ".txt" } # Over 4095 byte (ShortText limit)

      results = hash.select("txt", default_column: "filename")
      assert_equal 2, results.size 
    end
  end

  def test_grn_object
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

      hash["a"] = {text: "aaaa", filename:"a.txt", int: 1, float: 1.5, time: Time.at(2001)}

      raw = hash.grn

      assert_equal true, raw.have_column?("filename")
      assert_equal true, raw.have_column?("int")
      assert_equal true, raw.have_column?("float")
      assert_equal true, raw.have_column?("time")
      assert_equal false, raw.have_column?("timeee")

      assert_equal "ShortText", raw.column("text").range.name
      assert_equal "ShortText", raw.column("filename").range.name
      assert_equal "Int32"    , raw.column("int").range.name
      assert_equal "Float"    , raw.column("float").range.name
      assert_equal "Time"     , raw.column("time").range.name

      assert_equal true, raw.support_key? # GrnMini::Array is false
      assert_equal false, raw.support_sub_records?
    end
  end

  def test_sort
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

      hash["a"] = {name:"Tanaka",  age: 11, height: 162.5}
      hash["b"] = {name:"Suzuki",  age: 31, height: 170.0}
      hash["c"] = {name:"Hayashi", age: 21, height: 175.4}
      hash["d"] = {name:"Suzuki",  age:  5, height: 110.0}

      sorted_by_age = hash.sort(["age"])
      sorted_array = sorted_by_age.map {|r| {name: r.name, age: r.age}}
      assert_equal [{:name=>"Suzuki", :age=>5},
                    {:name=>"Tanaka", :age=>11},
                    {:name=>"Hayashi", :age=>21},
                    {:name=>"Suzuki", :age=>31}], sorted_array

      sorted_by_combination = hash.sort([{key: "name", order: :ascending},
                                          {key: "age" , order: :descending}])
      sorted_array = sorted_by_combination.map {|r| {name: r.name, age: r.age}}
      assert_equal [{:name=>"Hayashi", :age=>21},
                    {:name=>"Suzuki", :age=>31},
                    {:name=>"Suzuki", :age=>5},
                    {:name=>"Tanaka", :age=>11}], sorted_array
    end
  end

  def test_group_from_hash
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

      hash["a"] = {text:"aaaa.txt", suffix:"txt", type:1}
      hash["b"] = {text:"aaaa.doc", suffix:"doc", type:2}
      hash["c"] = {text:"aabb.txt", suffix:"txt", type:2}

      groups = GrnMini::Util::group_with_sort(hash, "suffix")

      assert_equal 2, groups.size
      assert_equal ["txt", 2], [groups[0].key, groups[0].n_sub_records]
      assert_equal ["doc", 1], [groups[1].key, groups[1].n_sub_records]
    end
  end
end
