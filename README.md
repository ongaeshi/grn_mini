# GrnMini

Groonga(Rroonga) wrapper for using easily. It is the KVS so easy to use.

## Installation

    $ gem install grn_mini

## Basic Usage

### Create a database with the name "test.db".

```ruby
require 'grn_mini'
array = GrnMini::Array.new("test.db")
```

### Add the record with the number column and text column.

Determine the column type when you first call "GrnMini::Array#add". (Add inverted index if data type is "string".)

```ruby
array.add(text: "aaa", number: 1)
```

### It is also possible to use the '<<'

```ruby
array << {text: "bbb", number: 2}
array << {text: "ccc", number: 3}
array.size  #=> 3
```

### Create a temporary database. (Useful for testing)

```ruby
GrnMini::Array.tmpdb do |array|
  array << {text: "aaa", number: 1}
  array << {text: "bbb", number: 2}
  array << {text: "ccc", number: 3}
end

# Delete temporary database
```

## Data Type

```ruby
GrnMini::Array.tmpdb do |array|
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

array = GrnMini::Array.new("test2.db")
array << {name:"Tanaka",  age: 11, height: 162.5}
array << {name:"Suzuki",  age: 31, height: 170.0}
```

### Read

```ruby
record = array[1] # Read from id (> 0)

# Get id
record.id       #=> 1

# Access function with the same name as the column name
record.name     #=> "Tanaka
record.age      #=> 11
record.height   #=> 162.5

# Groonga::Record#attributes is useful for debug
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

# Can't see deleted records if acess from Enumerable
array.first.id          #=> 2
array.first.attributes  #=> {"_id"=>2, "age"=>31, "height"=>170.0, "name"=>"Hayashi"}
```

It is also possible to pass the block.

```ruby
GrnMini::Array.tmpdb do |array|
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
`:text` column is set to the `:default_column` implicitly.

```ruby
GrnMini::Array.tmpdb do |array|
  array << {text:"aaa", number:1}
  array << {text:"bbb", number:20}
  array << {text:"bbb ccc", number:2}
  array << {text:"bbb", number:15}
  array << {text:"ccc", number:3}

  results = array.select("aaa")
  results.map {|record| record.attributes} #=> [{"_id"=>1, "_key"=>{"_id"=>1, "number"=>1, "text"=>"aaa"}, "_score"=>1}]

  # AND
  results = array.select("bbb ccc")
  results.map {|record| record.attributes} #=> [{"_id"=>2, "_key"=>{"_id"=>3, "number"=>2, "text"=>"bbb ccc"}, "_score"=>2}]

  # Specify column
  results = array.select("bbb number:<10")
  results.map {|record| record.attributes} #=> [{"_id"=>2, "_key"=>{"_id"=>3, "number"=>2, "text"=>"bbb ccc"}, "_score"=>2}]

  # AND, OR, Grouping
  results = array.select("bbb (number:<= 10 OR number:>=20)")
  results.map {|record| record.attributes} #=> [{"_id"=>2, "_key"=>{"_id"=>3, "number"=>2, "text"=>"bbb ccc"}, "_score"=>2}, {"_id"=>4, "_key"=>{"_id"=>2, "number"=>20, "text"=>"bbb"}, "_score"=>2}]

  # NOT
  results = array.select("bbb - ccc")
  results.map {|record| record.attributes}  #=> [{"_id"=>1, "_key"=>{"_id"=>2, "number"=>20, "text"=>"bbb"}, "_score"=>1}, {"_id"=>3, "_key"=>{"_id"=>4, "number"=>15, "text"=>"bbb"}, "_score"=>1}]
end 
```

Change `:default_column` to `:filename` column.

```ruby
GrnMini::Array.tmpdb do |array|
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

## Grouping

## Snippet

## Pagination

## Mini Search Engine

## Use Raw Groonga Object

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
