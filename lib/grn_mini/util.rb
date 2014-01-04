require 'groonga'

module GrnMini
  module Util
    module_function

    def group_with_sort(table, column)
      table.group(column).sort_by {|record| record.n_sub_records }.reverse
    end
  end
end
