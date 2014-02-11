require 'minitest_helper'

class TestSetupColumns < MiniTest::Unit::TestCase
  def test_repeat_setup_columns
    GrnMini::tmpdb do
      hash = GrnMini::Hash.new

      hash.setup_columns(name: "")
      hash.setup_columns(name: "")

      hash["a"] = {name: "aaa"}
      hash["b"] = {name: "bbb"}
      hash["c"] = {name: "aaa bbb ccc"}

      assert_equal 1, hash.select("name:@ccc").size
    end
  end

  def test_array
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {text:"aaa"}
      array << {text:"bbb"}
      array << {text:"ccc"}

      results = array.select("text:@bb")

      assert_equal 1, results.size
      assert_equal "bbb", results.first.text
    end
  end

  def test_number
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {text:"aaa", number: 1, float: 1.5, time: Time.at(1) }
      array << {text:"bbb", number: 2}
      array << {text:"ccc", number: 3}

      results = array.select("text:@bb")

      assert_equal 1, results.size
      assert_equal "bbb", results.first.text
    end
  end
  
  def test_table
    GrnMini::tmpdb do
      array = GrnMini::Array.new
      array2 = GrnMini::Array.new("A2")

      array.setup_columns(n: 0)
      array2.setup_columns(parent: array)

      array << {n: 1}
      array << {n: 2}
      array << {n: 3}
      array << {n: 4}

      array2 << {parent:  array[1]}
      array2 << {parent:  array[2]}
      array2 << {parent:  array[3]}

    end
  end

  def test_vector
    GrnMini::tmpdb do
      array = GrnMini::Array.new
      array.setup_columns(vec: [""])
    end
  end

end
