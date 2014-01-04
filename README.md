# GrnMini

Groonga(Rroonga) wrapper for using easily. It is the KVS it's so easy to use.

## Installation

    $ gem install grn_mini

Other installation is not required.

## Basic Usage

### Create a database with the name "test.db".

```ruby
require 'grn_mini'
array = GrnMini::Array.new(File.join(dir, "test.db"))
```

### Add the element with the number column and text column.

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



```
GrnMini::Array.tmpdb do |array|
  array << {text: "aaa", filename: "a.txt", int : 1, float: 1.5, time: Time.at(1999)}
  array << {text: "bbb", filename: "b.doc", int : 2, float: 2.5, time: Time.at(2000)}

  # ShortText
  array[1].text     #=> "aaa"
  array[1].filename #=> "text"

  # Int32
  array[1].int      #=> 1
  array[2].int      #=> 2

  # Float
  array[1].flaot    #=> 1.5
  array[2].flaot    #=> 2.5

  # Time
  array[1].time    #=> 1999-01-01
  array[2].time    #=> 2000-01-01
end
```

See also [8.4. Data type — Groonga documentation](http://groonga.org/docs/reference/types.html).

## Search

## Sort

## Grouping

## Snippet

## Pagination

## Mini Search Engine

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
