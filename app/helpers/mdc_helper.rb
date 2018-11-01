module MdcHelper
  def mdc_linear_slider(progress)
    raise "progress #{progress} is not in range 0..1" if progress.negative? || progress > 1
    buffer = content_tag('div', '', class: 'mdc-linear-progress__buffer')
    inner_span = content_tag('span', '', class: 'mdc-linear-progress__bar-inner')
    primary_bar = content_tag('div', inner_span, class: 'mdc-linear-progress__bar mdc-linear-progress__primary-bar')
    secondary_bar = content_tag('div', inner_span, class: 'mdc-linear-progress__bar mdc-linear-progress__secondary-bar')
    content_tag('div', buffer + primary_bar + secondary_bar, class: 'mdc-linear-progress', data: { progress: progress })
  end
end
