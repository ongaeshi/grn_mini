require 'minitest_helper'

class TestGrnMiniArray < MiniTest::Unit::TestCase
  def test_initialize
    Dir.mktmpdir do |dir|
      array = GrnMini::Array.new(File.join(dir, "test.db"))
    end
  end

  def test_add
    GrnMini::Array.tmpdb do |array|
      array.add(text:"aaa", number:1)
      assert_equal 1, array.size

      # alias << add
      array << {text:"bbb", number:2}
      assert_equal 2, array.size
    end 
  end

  def test_select
    GrnMini::Array.tmpdb do |array|
      array << {text:"aaa", number:1}
      array << {text:"bbb", number:2}
      array << {text:"ccc", number:3}

      results = array.select("bb")

      assert_equal 1, results.size
      assert_equal "bbb", results.first.text
    end 
  end

  def test_select2
    GrnMini::Array.tmpdb do |array|
      array << {text:"aaa", number:1}
      array << {text:"bbb", number:2}
      array << {text:"bbb", number:20}
      array << {text:"ccc", number:3}

      results = array.select("bb number:<10")

      assert_equal 1, results.size
      assert_equal "bbb", results.first.text
      assert_equal 2, results.first.number
    end 
  end

  def test_size
    GrnMini::Array.tmpdb do |array|
      assert_equal 0, array.size
      assert_equal 0, array.length
      
      array << {text:"aaa", number:1}
      array << {text:"bbb", number:2}
      assert_equal 2, array.size
      assert_equal 2, array.length
    end
  end

  def test_empty?
    GrnMini::Array.tmpdb do |array|
      assert_equal true, array.empty?

      array << {text:"aaa", number:1}
      assert_equal false, array.empty?
    end
  end

  def test_each
    GrnMini::Array.tmpdb do |array|
      array << {text:"aaa", number:1}
      array << {text:"bbb", number:2}
      array << {text:"ccc", number:3}

      array.each_with_index do |v, index|
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

  def test_read_by_id
    GrnMini::Array.tmpdb do |array|
      array << {text:"aaa", number:1}
      array << {text:"bbb", number:2}
      array << {text:"ccc", number:3}

      # id > 0
      assert_raises(GrnMini::Array::IdIsGreaterThanZero) { array[0] }

      assert_equal "aaa", array[1].text
      assert_equal "bbb", array[2].text
      assert_equal "ccc", array[3].text

      assert_equal nil, array[4].text
    end
  end

  def test_write_by_id
    GrnMini::Array.tmpdb do |array|
      array << {text:"aaa", number:1}
      array << {text:"bbb", number:2}
      array << {text:"ccc", number:3}

      assert_equal "bbb", array[2].text
      assert_equal 2, array[2].number

      array[2].text   = "BBB"
      array[2].number = 22

      assert_equal "BBB", array[2].text
      assert_equal 22, array[2].number
    end
  end

  def test_delete_by_id
    GrnMini::Array.tmpdb do |array|
      array << {text:"aaa", number:1}
      array << {text:"bbb", number:2}
      array << {text:"ccc", number:3}

      assert_equal 3, array.size

      array.delete(2)

      assert_equal 2, array.size

      # Deleted elements are not stuffed between
      assert_equal nil, array[2].text
      assert_equal 0, array[2].number

      # Can be accessed properly if use GrnMini::Array#each
      array.each_with_index do |v, index|
        case index
        when 0
          assert_equal "aaa", v.text
          assert_equal 1, v.number
        when 1
          assert_equal "ccc", v.text
          assert_equal 3, v.number
        end
        # p v.attributes
      end

      # New member id is '4'
      array << {text:"ddd", number:1}
      assert_equal "ddd", array[4].text
    end
  end

  def test_delete_by_block
    GrnMini::Array.tmpdb do |array|
      array << {text:"bbb", number:2}
      array << {text:"ccc", number:3}
      array << {text:"aaa", number:1}

      array.delete do |record|
        record.number >= 2
      end

      assert_equal 1, array.size
      assert_equal "aaa", array.first.text
      assert_equal 1, array.first.number
    end
  end

  def test_float_column
    GrnMini::Array.tmpdb do |array| 
      array << {text:"aaaa", float: 1.5}
      array << {text:"bbbb", float: 2.5}
      array << {text:"cccc", float: 3.5}

      assert_equal 2.5, array[2].float

      results = array.select("float:>2.6")
      assert_equal 3.5, results.first.float
    end
  end

  def test_time_column
    GrnMini::Array.tmpdb do |array| 
      array << {text:"aaaa", timestamp: Time.new(2013)} # 2013-01-01
      array << {text:"bbbb", timestamp: Time.new(2014)} # 2014-01-01
      array << {text:"cccc", timestamp: Time.new(2015)} # 2015-01-01

      assert_equal Time.new(2014), array[2].timestamp

      results = array.select("timestamp:<=#{Time.new(2013,12).to_i}")
      assert_equal 1, results.size
      assert_equal Time.new(2013), results.first.timestamp
    end    
  end

  def test_record_attributes
    GrnMini::Array.tmpdb do |array| 
      array << {text:"aaaa", int: 1}
      array << {text:"bbbb", int: 2}
      array << {text:"cccc", int: 3}

      assert_equal({"_id"=>1, "int"=>1, "text"=>"aaaa"}, array[1].attributes)
      assert_equal({"_id"=>2, "int"=>2, "text"=>"bbbb"}, array[2].attributes)
      assert_equal({"_id"=>3, "int"=>3, "text"=>"cccc"}, array[3].attributes)
    end
  end

  def test_assign_long_text_to_short_text
    GrnMini::Array.tmpdb do |array| 
      array << {filename:"a.txt"}
      array << {filename:"a"*4095 + ".txt" } # Over 4095 byte (ShortText limit)

      results = array.select("txt", default_column: "filename")
      assert_equal 2, results.size 
    end
  end

  def test_grn_object
    GrnMini::Array.tmpdb do |array| 
      array << {text: "aaaa", filename:"a.txt", int: 1, float: 1.5, time: Time.at(2001)}

      raw = array.grn

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

      assert_equal false, raw.support_key?
      assert_equal false, raw.support_sub_records?
    end
  end

  def test_sort
    GrnMini::Array.tmpdb do |array| 
      array << {name:"Tanaka",  age: 11, height: 162.5}
      array << {name:"Suzuki",  age: 31, height: 170.0}
      array << {name:"Hayashi", age: 21, height: 175.4}
      array << {name:"Suzuki",  age:  5, height: 110.0}

      sorted_by_age = array.sort(["age"])
      sorted_array = sorted_by_age.map { |r| {name: r.name, age: r.age}}
      assert_equal [{:name=>"Suzuki", :age=>5},
                    {:name=>"Tanaka", :age=>11},
                    {:name=>"Hayashi", :age=>21},
                    {:name=>"Suzuki", :age=>31}], sorted_array

      sorted_by_combination = array.sort([{key: "name", order: :ascending}, {key: "age", order: :descending}])
      sorted_array = sorted_by_combination.map { |r| {name: r.name, age: r.age}}
      assert_equal [{:name=>"Hayashi", :age=>21},
                    {:name=>"Suzuki", :age=>31},
                    {:name=>"Suzuki", :age=>5},
                    {:name=>"Tanaka", :age=>11}], sorted_array
    end
  end

  def test_group_from_array
    GrnMini::Array.tmpdb do |array| 
      array << {text:"aaaa.txt", suffix:"txt", type:1}
      array << {text:"aaaa.doc", suffix:"doc", type:2}
      array << {text:"aabb.txt", suffix:"txt", type:2}

      groups = GrnMini::Util::group_with_sort(array, "suffix")

      assert_equal 2, groups.size
      assert_equal ["txt", 2], [groups[0].key, groups[0].n_sub_records]
      assert_equal ["doc", 1], [groups[1].key, groups[1].n_sub_records]
    end
  end

end
