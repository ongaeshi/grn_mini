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

      10000.times { assert_equal 1, hash.select("name:@ccc").size }
    end
  end
end
