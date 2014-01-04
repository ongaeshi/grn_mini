require 'groonga'

module GrnMini
  module Util
    module_function

    def group_with_sort(table, column)
      table.group(column).sort_by {|record| record.n_sub_records }.reverse
    end

    def text_snippet_from_selection_results(table, open_tag = '<<', close_tag = ">>")
      table.expression.snippet([[open_tag, close_tag]])
    end

  end
end
