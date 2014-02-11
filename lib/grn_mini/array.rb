require 'grn_mini/table'

module GrnMini
  class NotSupportColumnType < RuntimeError; end

  class Array < Table
    def initialize(name = "Array")
      super(name,
            Groonga[name] || Groonga::Array.create(name: name, persistent: true),
            )
    end

    def add(hash)
      setup_columns(hash) unless @setup_columns_once
      @grn.add(hash)
    end

    alias << add

    class IdIsGreaterThanZero < RuntimeError; end
    
    def [](id)
      raise IdIsGreaterThanZero if id == 0
      @grn[id]
    end
    
    def delete(id = nil, &block)
      if block_given?
        @grn.delete(&block)
      else
        raise IdIsGreaterThanZero if id == 0
        @grn.delete(id)
      end
    end
  end
end
