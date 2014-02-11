require 'minitest_helper'

class TestGrnMini < MiniTest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GrnMini::VERSION
  end
end
