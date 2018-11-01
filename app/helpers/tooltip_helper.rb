module TooltipHelper
  def tooltip(text)
    { data: { toggle: 'tooltip' }, title: text }
  end
end
