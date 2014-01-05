# GrnMini

Groonga(Rroonga) wrapper for using easily. It is the KVS so easy to use.

## Installation

    $ gem install grn_mini

## Basic Usage

### Create a database with the name "test.db".

```ruby
require 'grn_mini'
array = GrnMini::Array.new(File.join(dir, "test.db"))
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

array = GrnMini::Array.new(File.join(dir, "test.db"))
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
record.attributes #=> {name: "Tanaka", age: 11, height: 162.5}
```

### Update

```ruby
array[2].name = "Hayashi"

array[2].attributes #=> {name: "Hayashi", age: 31, height: 170.0}
```

### Delete

Delete by passing id.

```ruby
array.delete(1)

# It returns 'nil' when you access a deleted record
array[1] #=> nil

# Can't see deleted records if acess from Enumerable
record = array.first # Return the record of id=2
record.attributes    #=> {name: "Hayashi", age: 31, height: 170.0}
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
  array.first.attributes #=> {name:"Suzuki",  age: 31, height: 170.0}
end
```

## Search

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
