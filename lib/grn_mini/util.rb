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

    def html_snippet_from_selection_results(table, open_tag = '<strong>', close_tag = "</strong>")
      table.expression.snippet([[open_tag, close_tag]], {html_escape: true})
    end
  end
end
