require 'grn_mini/table'

module GrnMini
  class Hash < Table
    def initialize(name = "Hash")
      super(name,
            Groonga[name] || Groonga::Hash.create(name: name, persistent: true))
    end

    def add(key, values)
      setup_columns(values) unless @setup_columns_once
      @grn.add(key, values)
    end

    def [](key)
      @grn[key]
    end
    
    def []=(key, value)
      add(key, value)
    end

    def delete(id = nil, &block)
      if block_given?
        @grn.delete(&block)
      else
        @grn.delete(id)
      end
    end

  end
end
