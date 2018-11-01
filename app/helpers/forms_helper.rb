module FormsHelper
  def inline_simple_form_for(path, options = {}, &block)
    options = options.deep_merge(html: { class: 'pmkt-inline-form' }, wrapper: :material_inline)
    simple_form_for(path, options, &block)
  end
end
