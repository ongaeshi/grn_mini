# GrnMini

Groonga(Rroonga) wrapper for using easily.

- Automatic generation of the column with data type
- Specification of column types explicitly
- Advanced Search Query
- Persistence
- Sort
- Grouping (Drill Down)
- Snippets
- Pagination
- Cooperation between multiple tables

## Installation

    $ gem install grn_mini

When you faild to install Rroonga, Please refer -> [File: install — rroonga - Ranguba](http://ranguba.org/rroonga/en/file.install.html)

## Basic Usage

### Create a database with the name "test.db".

```ruby
require 'grn_mini'
GrnMini::create_or_open("test.db")
```

### Add the record with the number column and text column.

Determine the column type when you first call "GrnMini::Array#add". (Add inverted index if data type is "string".)

```ruby
array = GrnMini::Array.new
array.add(text: "aaa", number: 1)
```

### It is also possible to use the '<<'

```ruby
array << {text: "bbb", number: 2}
array << {text: "ccc", number: 3}
array.size  #=> 3
```

### Open an existing database

```ruby
require 'grn_mini'
GrnMini::create_or_open("test.db")
array = GrnMini::Array.new
array.size   #=> 3
```

### Create a temporary database. (Useful for testing)

```ruby
GrnMini::tmpdb do
  array = GrnMini::Array.new
  array << {text: "aaa", number: 1}
  array << {text: "bbb", number: 2}
  array << {text: "ccc", number: 3}
end
# Delete temporary database
```

or

```ruby
require 'fileutils'

dir = GrnMini::tmpdb

array = GrnMini::Array.new
array << {text: "aaa", number: 1}
array << {text: "bbb", number: 2}
array << {text: "ccc", number: 3}

FileUtils.remove_entry_secure dir # Delete temporary database
```

## Create Hash

```ruby
require 'grn_mini'
GrnMini::create_or_open("test.db")
hash = GrnMini::Hash.new

# Add
hash["a"] = {text:"aaa", number:1}
hash["b"] = {text:"bbb", number:2}
hash["c"] = {text:"ccc", number:3}

# Read
hash["b"].text       #=> "bbb"

# Write
hash["b"].text = "BBB"
```

## Specify table name.
Default table name is "Array"(GrnMini::Array) or "Hash"(GrnMini::Hash).

```ruby
GrnMini::tmpdb do
  array = GrnMini::Array.new("Users")
  array << {text: "aaa", number: 1}
end
```

## Specification of column types explicitly

Use GrnMini::Table#setup_columns.

```ruby
GrnMini::tmpdb do
  array = GrnMini::Array.new

  # Specify dummy data
  array.setup_columns(filename: "",
                      int:      0,
                      float:    0.0,
                      time:     Time.new,
                      )
                      
  array << {filename: "a.txt", int: 1, float: 1.5, time: Time.at(1999)}
end
```

The following is the same meaning.

```ruby
GrnMini::tmpdb do
  array = GrnMini::Array.new
  # Automatic generation of the column with data type
  array << {filename: "a.txt", int: 1, float: 1.5, time: Time.at(1999)}
end
```

GrnMini::Table#setup_columns is useful for below.

- Specification of column types explicitly
- Refer to itself
- Cross-reference between tables
  - See "Cooperation between multiple tables"

## Data Type

```ruby
GrnMini::tmpdb do
  array = GrnMini::Array.new
  array << {filename: "a.txt", int: 1, float: 1.5, time: Time.at(1999)}
  array << {filename: "b.doc", int: 2, float: 2.5, time: Time.at(2000)}

  # ShortText
  array[1].filename #=> "a.txt"
  array[2].filename #=> "b.doc"

  # Int32
  array[1].int      #=> 1
  array[2].int      #=> 2

  # Float
  array[1].float    #=> 1.5
  array[2].float    #=> 2.5

  # Time
  array[1].time    #=> 1999-01-01
  array[2].time    #=> 2000-01-01
end
```

See also [8.4. Data type — Groonga documentation](http://groonga.org/docs/reference/types.html).

## Access Record

### Add

```ruby
require 'grn_mini'

GrnMini::create_or_open("test2.db")
array = GrnMini::Array.new
array << {name:"Tanaka",  age: 11, height: 162.5}
array << {name:"Suzuki",  age: 31, height: 170.0}
```

### Read

```ruby
record = array[1] # Read from id (> 0)
record.id         #=> 1
```

Access function with the same name as the column name

```ruby
record.name     #=> "Tanaka
record.age      #=> 11
record.height   #=> 162.5
```

Groonga::Record#attributes is useful for debug

```ruby
record.attributes #=> {"_id"=>1, "age"=>11, "height"=>162.5, "name"=>"Tanaka"}
```

### Update

```ruby
array[2].name = "Hayashi"
array[2].attributes #=> {"_id"=>2, "age"=>31, "height"=>170.0, "name"=>"Hayashi"}
```

### Delete

Delete by passing id.

```ruby
array.delete(1)

# It returns 'nil' value when you access a deleted record
array[1].attributes     #=> {"_id"=>1, "age"=>0, "height"=>0.0, "name"=>nil}

# Can't see deleted records if access from Enumerable
array.first.id          #=> 2
array.first.attributes  #=> {"_id"=>2, "age"=>31, "height"=>170.0, "name"=>"Hayashi"}
```

It is also possible to pass the block.

```ruby
GrnMini::tmpdb do
  array = GrnMini::Array.new

  array << {name:"Tanaka",  age: 11, height: 162.5}
  array << {name:"Suzuki",  age: 31, height: 170.0}
  array << {name:"Hayashi", age: 20, height: 165.0}

  array.delete do |record|
    record.age <= 20
  end

  array.size             #=> 1
  array.first.attributes #=> {"_id"=>2, "age"=>31, "height"=>170.0, "name"=>"Suzuki"}
end
```

## Search

Use GrnMini::Array#select method.

```ruby
GrnMini::tmpdb do
  array = GrnMini::Array.new

  array << {text:"aaa", number:1}
  array << {text:"bbb", number:20}
  array << {text:"bbb ccc", number:2}
  array << {text:"bbb", number:15}
  array << {text:"ccc", number:3}

  results = array.select("text:aaa")
  results.map {|record| record.attributes} #=> [{"_id"=>1, "_key"=>{"_id"=>1, "number"=>1, "text"=>"aaa"}, "_score"=>1}]

  # AND
  results = array.select("text:@bbb text:@ccc")
  results.map {|record| record.attributes} #=> [{"_id"=>2, "_key"=>{"_id"=>3, "number"=>2, "text"=>"bbb ccc"}, "_score"=>2}]

  # Specify column
  results = array.select("text:@bbb number:<10")
  results.map {|record| record.attributes} #=> [{"_id"=>2, "_key"=>{"_id"=>3, "number"=>2, "text"=>"bbb ccc"}, "_score"=>2}]

  # AND, OR, Grouping
  results = array.select("text:@bbb (number:<= 10 OR number:>=20)")
  results.map {|record| record.attributes} #=> [{"_id"=>2, "_key"=>{"_id"=>3, "number"=>2, "text"=>"bbb ccc"}, "_score"=>2}, {"_id"=>4, "_key"=>{"_id"=>2, "number"=>20, "text"=>"bbb"}, "_score"=>2}]

  # NOT
  results = array.select("text:@bbb - text:@ccc")
  results.map {|record| record.attributes}  #=> [{"_id"=>1, "_key"=>{"_id"=>2, "number"=>20, "text"=>"bbb"}, "_score"=>1}, {"_id"=>3, "_key"=>{"_id"=>4, "number"=>15, "text"=>"bbb"}, "_score"=>1}]
end 
```

Use `:default_column` option.

```ruby
GrnMini::tmpdb do
  array = GrnMini::Array.new

  array << {text: "txt", filename:"a.txt"}
  array << {text: "txt", filename:"a.doc"}
  array << {text: "txt", filename:"a.rb"}

  # Specify column
  results = array.select("filename:@txt")
  results.first.attributes  #=> {"_id"=>1, "_key"=>{"_id"=>1, "filename"=>"a.txt", "text"=>"txt"}, "_score"=>1}

  # Change default_column
  results = array.select("txt", default_column: "filename")
  results.first.attributes  #=> {"_id"=>1, "_key"=>{"_id"=>1, "filename"=>"a.txt", "text"=>"txt"}, "_score"=>1}
end
```

See also [8.10.1. Query syntax](http://groonga.org/docs/reference/grn_expr/query_syntax.html), [Groonga::Table#select](http://ranguba.org/rroonga/en/Groonga/Table.html#select-instance_method)

## Sort

Specify column name to sort.

```ruby
GrnMini::tmpdb do
  array = GrnMini::Array.new

  array << {name:"Tanaka",  age: 11, height: 162.5}
  array << {name:"Suzuki",  age: 31, height: 170.0}
  array << {name:"Hayashi", age: 21, height: 175.4}
  array << {name:"Suzuki",  age:  5, height: 110.0}

  sorted = array.sort(["age"])

  sorted.map {|r| {name: r.name, age: r.age}}
    #=> [{:name=>"Suzuki",  :age=> 5},
    #    {:name=>"Tanaka",  :age=>11},
    #    {:name=>"Hayashi", :age=>21},
    #    {:name=>"Suzuki",  :age=>31}]
end
```

Combination sort.

```ruby
sorted = array.sort([{key: "name", order: :ascending},
                     {key: "age" , order: :descending}])

sorted.map {|r| {name: r.name, age: r.age}}
    #=> [{:name=>"Hayashi", :age=>21},
    #    {:name=>"Suzuki",  :age=>31},
    #    {:name=>"Suzuki",  :age=> 5},
    #    {:name=>"Tanaka",  :age=>11}]
```

## Grouping

Drill down aka.

```ruby
GrnMini::tmpdb do
  array = GrnMini::Array.new

  array << {text:"aaaa.txt", suffix:"txt", type:1}
  array << {text:"aaaa.doc", suffix:"doc", type:2}
  array << {text:"aabb.txt", suffix:"txt", type:2}

  groups = GrnMini::Util::group_with_sort(array, "suffix")

  groups.size                               #=> 2
  [groups[0].key, groups[0].n_sub_records]  #=> ["txt", 2]
  [groups[1].key, groups[1].n_sub_records]  #=> ["doc", 1]
end
```

Grouping from selection results.

```ruby
GrnMini::tmpdb do
  array = GrnMini::Array.new

  array << {text:"aaaa", suffix:"txt"}
  array << {text:"aaaa", suffix:"doc"}
  array << {text:"aaaa", suffix:"txt"}
  array << {text:"cccc", suffix:"txt"}

  results = array.select("text:@aa")
  groups = GrnMini::Util::group_with_sort(results, "suffix")

  groups.size                               #=> 2
  [groups[0].key, groups[0].n_sub_records]  #=> ["txt", 2]
  [groups[1].key, groups[1].n_sub_records]  #=> ["doc", 1]
end
```

## Snippet

Display of keyword surrounding text. It is often used in search engine.
Use `GrnMini::Util::text_snippet_from_selection_results`.

```ruby
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
EOF

  results = array.select("text:@This pen")
  snippet = GrnMini::Util::text_snippet_from_selection_results(results)

  record = results.first
  segments = snippet.execute(record.text)
  segments.size #=> 2
  segments[0]   #=> "[1] <<This>> is a <<pen>> pep pea pek pet.\n------------------------------\n------------------------------\n---"
  segments[1]   #=> "--------\n------------------------------\n[2] <<This>> is a <<pen>> pep pea pek pet.\n-------------------------"
end
```

`GrnMini::Util::html_snippet_from_selection_results` is HTML escaped.

```ruby
GrnMini::tmpdb do
  array = GrnMini::Array.new

  array << {text: <<EOF, filename: "aaa.txt"}
<html>
  <div>This is a pen pep pea pek pet.</div>
</html>
EOF

  results = array.select("text:@This pen")
  snippet = GrnMini::Util::html_snippet_from_selection_results(results, '<span class="strong">', '</span>') # Default value is '<strong>', '</strong>'

  record = results.first
  segments = snippet.execute(record.text)
  segments.size   #=> 1
  segments.first  #=> "&lt;html&gt;\n  &lt;div&gt;<span class=\"strong\">This</span> is a <span class=\"strong\">pen</span> pep pea pek pet.&lt;/div&gt;\n&lt;/html&gt;\n"
end
```

See also [Groonga::Expression#snippet](http://ranguba.org/rroonga/en/Groonga/Expression.html#snippet-instance_method)

## Pagination

 #paginate is more convenient than #sort if you want a pagination.

```ruby
GrnMini::tmpdb do
  array = GrnMini::Array.new

  array << {text: "aaaa", filename: "1.txt"}
  array << {text: "aaaa aaaa", filename: "2a.txt"}
  array << {text: "aaaa aaaa aaaa", filename: "3.txt"}
  array << {text: "aaaa aaaa", filename: "2b.txt"}
  array << {text: "aaaa aaaa", filename: "2c.txt"}
  array << {text: "aaaa aaaa", filename: "2d.txt"}
  array << {text: "aaaa aaaa", filename: "2e.txt"}
  array << {text: "aaaa aaaa", filename: "2f.txt"}

  results = array.select("text:@aaaa")

  # -- page1 --
  page_entries = results.paginate([["_score", :desc]], :page => 1, :size => 5)

  # Total number of record
  page_entries.n_records    #=> 8

  # Page offset
  page_entries.start_offset #=> 1
  page_entries.end_offset   #=> 5

  # Page entries
  page_entries.size         #=> 5

  # -- page2 --
  page_entries = results.paginate([["_score", :desc]], :page => 2, :size => 5)

  # Sample page content display
  puts "#{page_entries.n_records} hit. (#{page_entries.start_offset} - #{page_entries.end_offset})"
  page_entries.each do |record|
    puts "#{record.filename}: #{record.text}"
  end

  #=> 8 hit. (6 - 8)
  #   2b.txt: aaaa aaaa
  #   2f.txt: aaaa aaaa
  #   1.txt: aaaa
end
```

See also [Groonga::Table#pagenate](http://ranguba.org/rroonga/en/Groonga/Table.html#paginate-instance_method)

## Cooperation between multiple tables

Micro blog sample.

```ruby
GrnMini::tmpdb do
  users = GrnMini::Hash.new("Users")
  articles = GrnMini::Hash.new("Articles")

  users.setup_columns(name: "",
                      favorites: [articles]
                      )

  articles.setup_columns(author: users,
                         text: ""
                         )

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

  # Search record.favorites
  users.select { |record| record.favorites == "aaa:1" }    #=> ["aaa", "ccc"]
  users.select { |record| record.favorites == "aaa:2" }  #=> ["bbb"]

  # Search record.favorites.text
  users.select { |record| record.favorites.text =~ "111" } #=> ["aaa", "ccc"]
end
```
