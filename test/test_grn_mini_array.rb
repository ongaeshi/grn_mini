require 'minitest_helper'

class TestGrnMiniArray < MiniTest::Unit::TestCase
  def test_initialize
    GrnMini::tmpdb do
      array = GrnMini::Array.new
    end
  end

  def test_add
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array.add(text:"aaa", number:1)
      assert_equal 1, array.size

      # alias << add
      array << {text:"bbb", number:2}
      assert_equal 2, array.size
    end 
  end

  def test_select
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {text:"aaa", number:1}
      array << {text:"bbb", number:2}
      array << {text:"ccc", number:3}

      results = array.select("text:@bb")

      assert_equal 1, results.size
      assert_equal "bbb", results.first.text
    end 
  end

  def test_select2
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {text:"aaa", number:1}
      array << {text:"bbb", number:2}
      array << {text:"bbb", number:20}
      array << {text:"ccc", number:3}

      results = array.select("text:@bb number:<10")

      assert_equal 1, results.size
      assert_equal 2, results.first.key.id
      assert_equal "bbb", results.first.text
      assert_equal 2, results.first.number
    end 
  end

  def test_size
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      assert_equal 0, array.size
      
      array << {text:"aaa", number:1}
      array << {text:"bbb", number:2}
      assert_equal 2, array.size
    end
  end

  def test_empty?
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      assert_equal true, array.empty?

      array << {text:"aaa", number:1}
      assert_equal false, array.empty?
    end
  end

  def test_each
    GrnMini::tmpdb do
      array = GrnMini::Array.new

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
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {text:"aaa", number:1}
      array << {text:"bbb", number:2}
      array << {text:"ccc", number:3}

      # id > 0
      assert_raises(GrnMini::Array::IdIsGreaterThanZero) { array[0] }

      record = array[1]
      assert_equal 1, record.id

      assert_equal "aaa", array[1].text
      assert_equal "bbb", array[2].text
      assert_equal "ccc", array[3].text

      assert_equal nil, array[4].text
    end
  end

  def test_write_by_id
    GrnMini::tmpdb do
      array = GrnMini::Array.new

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
    GrnMini::tmpdb do
      array = GrnMini::Array.new

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
    GrnMini::tmpdb do
      array = GrnMini::Array.new

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
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {text:"aaaa", float: 1.5}
      array << {text:"bbbb", float: 2.5}
      array << {text:"cccc", float: 3.5}

      assert_equal 2.5, array[2].float

      results = array.select("float:>2.6")
      assert_equal 3.5, results.first.float
    end
  end

  def test_time_column
    GrnMini::tmpdb do
      array = GrnMini::Array.new

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
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {text:"aaaa", int: 1}
      array << {text:"bbbb", int: 2}
      array << {text:"cccc", int: 3}

      assert_equal({"_id"=>1, "int"=>1, "text"=>"aaaa"}, array[1].attributes)
      assert_equal({"_id"=>2, "int"=>2, "text"=>"bbbb"}, array[2].attributes)
      assert_equal({"_id"=>3, "int"=>3, "text"=>"cccc"}, array[3].attributes)
    end
  end

  def test_assign_long_text_to_short_text
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {filename:"a.txt"}
      array << {filename:"a"*4095 + ".txt" } # Over 4095 byte (ShortText limit)

      results = array.select("txt", default_column: "filename")
      assert_equal 2, results.size 
    end
  end

  def test_grn_object
    GrnMini::tmpdb do
      array = GrnMini::Array.new

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
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {name:"Tanaka",  age: 11, height: 162.5}
      array << {name:"Suzuki",  age: 31, height: 170.0}
      array << {name:"Hayashi", age: 21, height: 175.4}
      array << {name:"Suzuki",  age:  5, height: 110.0}

      sorted_by_age = array.sort(["age"])
      sorted_array = sorted_by_age.map {|r| {name: r.name, age: r.age}}
      assert_equal [{:name=>"Suzuki", :age=>5},
                    {:name=>"Tanaka", :age=>11},
                    {:name=>"Hayashi", :age=>21},
                    {:name=>"Suzuki", :age=>31}], sorted_array

      sorted_by_combination = array.sort([{key: "name", order: :ascending},
                                          {key: "age" , order: :descending}])
      sorted_array = sorted_by_combination.map {|r| {name: r.name, age: r.age}}
      assert_equal [{:name=>"Hayashi", :age=>21},
                    {:name=>"Suzuki", :age=>31},
                    {:name=>"Suzuki", :age=>5},
                    {:name=>"Tanaka", :age=>11}], sorted_array
    end
  end

  def test_group_from_array
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {text:"aaaa.txt", suffix:"txt", type:1}
      array << {text:"aaaa.doc", suffix:"doc", type:2}
      array << {text:"aabb.txt", suffix:"txt", type:2}

      groups = GrnMini::Util::group_with_sort(array, "suffix")

      assert_equal 2, groups.size
      assert_equal ["txt", 2], [groups[0].key, groups[0].n_sub_records]
      assert_equal ["doc", 1], [groups[1].key, groups[1].n_sub_records]
    end
  end

  def test_group_from_selection_results
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {text:"aaaa", suffix:"txt"}
      array << {text:"aaaa", suffix:"doc"}
      array << {text:"aaaa", suffix:"txt"}
      array << {text:"cccc", suffix:"txt"}

      results = array.select("text:@aa")
      groups = GrnMini::Util::group_with_sort(results, "suffix")

      assert_equal 2, groups.size
      assert_equal ["txt", 2], [groups[0].key, groups[0].n_sub_records]
      assert_equal ["doc", 1], [groups[1].key, groups[1].n_sub_records]
    end
  end

  def test_text_snippet_from_selection_results
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {text: <<EOF, filename: "aaa.txt"}
[1] This is a pen pep pea pek pet.
------------------------------
------------------------------
------------------------------
------------------------------
[2] This is a pen pep pea pek pet.
------------------------------
------------------------------
------------------------------
------------------------------
------------------------------
EOF

      results = array.select("This pen", default_column: "text")
      snippet = GrnMini::Util::text_snippet_from_selection_results(results)

      record = results.first
      segments = snippet.execute(record.text)
      assert_equal 2, segments.size 
      assert_match /\[1\]<< This>> is a<< pen>> pep pea pek pet./, segments[0]
      assert_match /\[2\]<< This>> is a<< pen>> pep pea pek pet./, segments[1]
    end
  end

  def test_html_snippet_from_selection_results
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {text: <<EOF, filename: "aaa.txt"}
<html>
  <div>This is a pen pep pea pek pet.</div>
</html>
EOF

      results = array.select("text:@This text:@pen")
      snippet = GrnMini::Util::html_snippet_from_selection_results(results)

      record = results.first
      segments = snippet.execute(record.text)
      assert_equal 1, segments.size
      assert_equal "&lt;html&gt;\n  &lt;div&gt;<strong>This</strong> is a<strong> pen</strong> pep pea pek pet.&lt;/div&gt;\n&lt;/html&gt;\n", segments.first
    end
  end

  def test_paginate
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array << {text: "aaaa", filename: "1.txt"}
      array << {text: "aaaa aaaa", filename: "2a.txt"}
      array << {text: "aaaa aaaa aaaa", filename: "3.txt"}
      array << {text: "aaaa aaaa", filename: "2b.txt"}
      array << {text: "aaaa aaaa", filename: "2c.txt"}
      array << {text: "aaaa aaaa", filename: "2d.txt"}

      results = array.select { |r| r.text =~ "aaaa" }

      # page1
      page_entries = results.paginate([["_score", :desc]], :page => 1, :size => 5)
      assert_equal 6, page_entries.n_records
      assert_equal 1, page_entries.start_offset
      assert_equal 5, page_entries.end_offset
      assert_equal "3.txt", page_entries.first.filename

      # page2
      page_entries = results.paginate([["_score", :desc]], :page => 2, :size => 5)
      assert_equal 6, page_entries.n_records
      assert_equal 6, page_entries.start_offset
      assert_equal 6, page_entries.end_offset
      assert_equal "1.txt", page_entries.first.filename
    end
  end

  def test_multi_table
    Dir.mktmpdir do |dir|
      GrnMini::create_or_open(File.join(dir, "test.db"))
      
      users = GrnMini::Array.new("Users")
      users << {name: "aaa", age: 10}
      users << {name: "bbb", age: 20}
      users << {name: "ccc", age: 30}
      
      articles = GrnMini::Array.new("Articles")
      articles << {title: "Hello", text: "hello everyone."}

      assert Groonga["Users"]
      assert_equal 3, users.size

      assert Groonga["Articles"]
      assert_equal 1, articles.size
    end
  end

  def test_multi_table_select
    GrnMini::tmpdb do
      users = GrnMini::Array.new("Users")
      users << {name: "aaa", age: 10, text: ""}
      users << {name: "bbb", age: 20}
      users << {name: "ccc", age: 30}
      
      articles = GrnMini::Array.new("Articles")
      articles << {title: "1", text: "111 aaa"}
      articles << {title: "2", text: "222 bbb"}
      articles << {title: "3", text: "333 ccc"}

      results = users.select("222 OR ccc", default_column: "text")
      assert_equal 0, results.size
      
      results = articles.select("222 OR ccc", default_column: "text")
      assert_equal 2, results.size
      assert_equal "2", results.first.title
    end
  end

  def test_setup_columns
    GrnMini::tmpdb do
      array = GrnMini::Array.new

      array.setup_columns(
        name: "",
        age:  0,
      )

      array << {name: "bbb", age: 20 }
      assert_raises(Groonga::NoSuchColumn) { array << {name: "aaa", age: 10, text: ""} }
      assert_equal 2, array.size
    end
  end

  def test_setup_columns_groonga_table
    GrnMini::tmpdb do
      users = GrnMini::Array.new("Users")

      users.setup_columns(
        parent: users,
      )

      users << {}
      users << { parent: users[1] }
      users << { parent: users[2] }

      # No error ..
      # users << { parent: 123456 }
      # users << { parent: 1.5 }
      # users << { parent: Time.now }

      assert_equal      nil, users[1].parent
      assert_equal users[1], users[2].parent
      assert_equal users[1], users[3].parent.parent
    end
  end

  def test_setup_columns_vector
    GrnMini::tmpdb do
      array = GrnMini::Array.new
      array.setup_columns(links:[""])

      array << {}
      assert_equal [], array[1].links

      # Nothing happens ..
      array[1].links << "http://ongaeshi.me"
      assert_equal 0, array[1].links.size

      # Use links=
      array[1].links = ["http://ongaeshi.me", "http://yahoo.co.jp"]
      assert_equal 2, array[1].links.size

      array << { links: ["aaa", "bbb", "ccc"]}
      array << { links: ["AAA"]}

      # array.each do |record|
      #   p record.attributes
      # end

      assert_equal 3, array.size
      assert_equal 3, array[2].links.size
    end
  end

  def test_setup_columns_vector2
    GrnMini::tmpdb do
      array = GrnMini::Array.new
      array.setup_columns(strs:    [""],
                          numbers: [0],
                          floats:  [0.1],
                          times:   [Time.new],
                          arrays:  [array]
                          )

      array.add(strs: ["AAA", "BBB"],
                numbers: [1, 2, 3],
                floats: [0.1, 0.2, 0.3],
                times:  [Time.at(0), Time.at(1), Time.at(3)],
                arrays: []
                )
      array.add(arrays: [array[1]])
      array.add(arrays: [array[1], array[2]])

      # First element is [1..N], Second and subsequent elements is [0..N-1].
      assert_equal 0.2, array[3].arrays[1].arrays[0].floats[1]
    end    
  end

  def test_tweet
    GrnMini::tmpdb do
      users = GrnMini::Array.new("Users")
      tweets = GrnMini::Array.new("Tweets")

      users.setup_columns(name: "A Name"
                          )
      tweets.setup_columns(user: users,
                           time: Time.new,
                           text: "A Tweet.",
                           replies: [tweets]
                           )

      users << { name: "AAA" }
      users << { name: "BBB" }

      tweets << { user: users[1], time: Time.at(1), text: "AAA Tweet 1" }
      tweets << { user: users[2], time: Time.at(2), text: "BBB Tweet 1" }
      tweets << { user: users[1], time: Time.at(3), text: "AAA Tweet 2" }
      tweets << { user: users[1], time: Time.at(4), text: "Re: BBB Tweet 1" }
      tweets << { user: users[2], time: Time.at(5), text: "Re: Re: BBB Tweet 1" }
      tweets[3].replies = [tweets[4], tweets[5]]

      # tweets.each do |record|
      #   p record.attributes
      # end

      assert_equal 3, tweets.select("user:1").size
      assert_equal "AAA Tweet 2", tweets.select("user:1 text:@Tweet text:@2").first.text
      assert_equal 2, tweets.select("user:2").size
    end    
  end

  def test_not_support_column_type
    GrnMini::tmpdb do
      array = GrnMini::Array.new
      assert_raises(GrnMini::NotSupportColumnType) { array.setup_columns(error: Hash) } 
    end    
  end
end
