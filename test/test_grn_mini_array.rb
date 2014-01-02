require 'minitest_helper'

class TestGrnMiniArray < MiniTest::Unit::TestCase
  def test_empty
    GrnMini::Array.tmpdb do |array|
      assert_equal true, array.empty?
    end 
  end
end
