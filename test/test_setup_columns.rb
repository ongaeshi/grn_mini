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
end
