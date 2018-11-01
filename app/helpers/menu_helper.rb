module MenuHelper
  def menu_toggle(name, text)
    toggled_name = "#{name}__toggle"
    classes = ['mdc-menu-toggle', toggled_name]
    link_to text, '#', id: toggled_name, data: { toggle: "##{name}__list" }, class: classes
  end

  def menu_items(name, items)
    listed_name = "#{name}__list"
    content_tag('div', id: listed_name, class: 'mdc-menu', tabindex: '-1') do
      content_tag(:ul, class: "#{listed_name} mdc-menu__items mdc-list", role: "menu", 'aria-hidden': true) do
        capture do
          items.each do |item|
            concat content_tag('li', item, class: 'mdc-list-item', role: 'menuitem', tabindex: '0')
          end
        end
      end
    end
  end
end
