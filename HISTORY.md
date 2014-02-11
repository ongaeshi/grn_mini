# HISTORY - grn_mini

## 0.5 - 2014/02/11

- Use Groonga::Schema
  - Can use setup_columns when table column defined already.

## 0.4 - 2014/02/01

- GrnMini
  - Add GrnMini::create_or_open(db_name)
  - Add GrnMini::tmpdb

- GrnMini::Table
  - Extract common function of Array and Hash
    - Array < Table
    - Hash < Table
  - Add Table#setup_columns
    - Specification of column types explicitly
    - Support cross-reference between table
  - Support new column type
    - VECTOR_COLUMN
    - GrnMini::Table, Groonga::Table (with define_index_column)
    - "BOOL"
  - GrnMini::Table#select
    - Support block argument
    - Quit the support of {default_column: "text”}

- GrnMini::Array
  - Array.new(database_name) -> Array.new(table_name)
  - Remove Array::tmpdb

- GrnMini::Hash
  - Hash.new(database_name) -> Hash.new(table_name)
  - Remove Hash::tmpdb

- README.md
  - Fix to the new API sample code

## 0.3 - 2014/01/10

- Support GrnMini::Hash

## 0.2 - 2014/01/07

- Support snippet

## 0.1 - 2014/01/05

- 1st Release
