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

end
