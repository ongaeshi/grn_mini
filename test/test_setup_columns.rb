require 'minitest_helper'

class TestSetupColumns < MiniTest::Test
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

  def column_array(table)
    table.columns.map{ |c| c.local_name }
  end

  def test_columns
    GrnMini::tmpdb do
      array = GrnMini::Array.new
      array.setup_columns(str: "")

      assert_equal ["str"], column_array(Groonga["Array"])
      assert_equal ["Array_str"], column_array(Groonga["Terms"])

      array2 = GrnMini::Array.new("Array2")
      array2.setup_columns(str: "", number: 1, float: 0.1, time: Time.at(0))

      assert_equal ["float", "number", "str", "time"], column_array(Groonga["Array2"])
      assert_equal ["Array2_str", "Array_str"], column_array(Groonga["Terms"])

      # Change array schema
      array.setup_columns(str: "", str2: "", number: 1)
      assert_equal ["number", "str", "str2"], column_array(Groonga["Array"])
      assert_equal ["Array2_str", "Array_str", "Array_str2"], column_array(Groonga["Terms"])
    end
  end

  def test_multi_table_columns
    GrnMini::tmpdb do
      users = GrnMini::Hash.new("Users")
      articles = GrnMini::Hash.new("Articles")

      users.setup_columns(name: "", favorites: [articles])
      articles.setup_columns(author: users, text: "")

      users["aaa"] = {name: "Mr.A"}
      users["bbb"] = {name: "Mr.B"}
      users["ccc"] = {name: "Mr.C"}

      articles["aaa:1"] = {author: "aaa", text: "111"}
      articles["aaa:2"] = {author: "aaa", text: "222"}
      articles["aaa:3"] = {author: "aaa", text: "333"}
      articles["bbb:1"] = {author: "bbb", text: "111"}
      articles["bbb:2"] = {author: "bbb", text: "222"}
      articles["ccc:1"] = {author: "ccc", text: "111"}

      users["aaa"].favorites = ["aaa:1", "bbb:2"]
      users["bbb"].favorites = ["aaa:2"]
      users["ccc"].favorites = ["aaa:1", "bbb:1", "ccc:1"]

      assert_equal ["favorites", "name"], column_array(Groonga["Users"])
      assert_equal ["Users_favorites", "author", "text"], column_array(Groonga["Articles"])
      assert_equal ["Articles_text", "Users_name"], column_array(Groonga["Terms"])
    end
  end
end
