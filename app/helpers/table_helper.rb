module TableHelper
  def pmkt_table(_args = {}, &block)
    block_content = capture(&block)
    content_tag 'div', class: 'table-responsive' do
      capture do
        concat content_tag 'table', block_content, class: 'pmkt-table'
      end
    end
  end
end
