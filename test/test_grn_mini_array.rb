require 'minitest_helper'

class TestGrnMiniArray < MiniTest::Unit::TestCase
  def test_initialize
    Dir.mktmpdir do |dir|
      array = GrnMini::Array.new(File.join(dir, "test.db"))
    end
  end

  def test_add
    GrnMini::Array.tmpdb do |array|
      array << {text:"aaa", number:1}
      assert_equal 1, array.size

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
      
      array << {text:"aaa", number:1}
      array << {text:"bbb", number:2}
      assert_equal 2, array.size
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
end
