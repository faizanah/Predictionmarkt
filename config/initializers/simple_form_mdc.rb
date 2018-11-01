Dir["#{Rails.root}/lib/simple_form/*.rb"].each { |file| require file }

SimpleForm.setup do |config|
  config.error_notification_class = 'alert alert-danger'
  config.button_class = 'btn-action'
  config.boolean_style = :inline # mdc switch compatibility

  config.wrappers :material_switch, tag: 'div', class: 'input-group' do |c|
    c.wrapper :div, class: 'input-group-horizontal' do |h|
      h.wrapper :div, class: 'mdc-switch' do |cc|
        cc.use :input, class: 'mdc-switch__native-control'
        cc.wrapper tag: 'div', class: 'mdc-switch__background' do |ca|
          ca.wrapper tag: 'div', class: 'mdc-switch__knob' do
          end
        end
      end
      h.use :label, class: 'mdc-switch-label'
    end
  end

  config.wrappers :material_slider_discrete, tag: 'div',
    input_html: { type: 'hidden' },
    class: 'input-group' do |a|
    a.wrapper :div, class: 'input-group-vertical' do |b|
      b.use :input # works only with as: :percentage, check app/inputs
      b.wrapper 'slider', tag: 'div', class: 'mdc-slider mdc-slider--discrete' do |c|
        c.wrapper tag: 'div', class: 'mdc-slider__track-container' do |d|
          d.wrapper 'track', tag: 'div', class: 'mdc-slider__track' do
          end
        end
        c.wrapper tag: 'div', class: 'mdc-slider__thumb-container' do |d|
          d.wrapper tag: 'div', class: 'mdc-slider__pin' do |e|
            e.wrapper tag: 'span', class: 'mdc-slider__pin-value-marker' do
            end
          end
          d.wrapper tag: 'svg', class: 'mdc-slider__thumb', html: { width: 21, height: 21 } do |e|
            e.wrapper tag: 'circle', html: { cx: 10.5, cy: 10.5, r: 7.875 } do
            end
          end
          d.wrapper tag: 'div', class: 'mdc-slider__focus-ring' do
          end
        end
      end
      #b.wrapper :textfield, tag: 'div', class: 'mdc-text-field mdc-slider__text-field' do |ba|
      #  ba.use :input, class: 'mdc-text-field__input'
      #  ba.wrapper tag: 'div', class: 'mdc-text-field__bottom-line' do
      #  end
      #end
    end
  end

  config.wrappers :material_slider, tag: 'div',
    input_html: { type: 'hidden' },
    class: 'input-group' do |a|
    a.wrapper :div, class: 'input-group-vertical' do |b|
      b.use :input # works only with as: :percentage, check app/inputs
      b.wrapper 'slider', tag: 'div', class: 'mdc-slider' do |c|
        c.wrapper tag: 'div', class: 'mdc-slider__track-container' do |d|
          d.wrapper 'track', tag: 'div', class: 'mdc-slider__track' do
          end
        end
        c.wrapper tag: 'div', class: 'mdc-slider__thumb-container' do |d|
          d.wrapper tag: 'svg', class: 'mdc-slider__thumb', html: { width: 21, height: 21 } do |e|
            e.wrapper tag: 'circle', html: { cx: 10.5, cy: 10.5, r: 7.875 } do
            end
          end
          d.wrapper tag: 'div', class: 'mdc-slider__focus-ring' do
          end
        end
      end
      #b.wrapper :textfield, tag: 'div', class: 'mdc-text-field mdc-slider__text-field' do |ba|
      #  ba.use :input, class: 'mdc-text-field__input'
      #  ba.wrapper tag: 'div', class: 'mdc-text-field__bottom-line' do
      #  end
      #end
    end
  end

  config.wrappers :material_select, class: 'input-group', error_class: 'is-invalid' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :textfield, tag: 'div', class: 'mdc-text-field' do |ba|
      ba.use :icon
      ba.use :input, class: 'mdc-select'
      ba.use :label, class: 'mdc-floating-label'
    end
    b.use :error, wrap_with: { tag: :p, class: 'mdc-text-field-helper-text mdc-text-field-helper-text--validation-msg' }
  end

  config.wrappers :material, class: 'input-group', error_class: 'is-invalid' do |b|
    b.use :html5
    # b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.wrapper :textfield, tag: 'div', class: 'mdc-text-field', error_class: 'mdc-text-field--invalid' do |ba|
      ba.use :icon
      ba.use :input, class: 'mdc-text-field__input'
      ba.use :label, class: 'mdc-floating-label'
      ba.wrapper tag: 'div', class: 'mdc-text-field__bottom-line' do
      end
    end
    b.use :hint, wrap_with: { tag: :p, class: 'mdc-text-field-helper-text mdc-text-field-helper-text--persistent' }
    b.use :error, wrap_with: { tag: :p, class: 'mdc-text-field-helper-text mdc-text-field-helper-text--validation-msg' }

    ## full_messages_for
    # If you want to display the full error message for the attribute, you can
    # use the component :full_error, like:
    #
    # b.use :full_error, wrap_with: { tag: :span, class: :error }
  end

  config.wrappers :material_inline, class: 'input-group', error_class: 'is-invalid' do |b|
    b.use :html5
    b.optional :maxlength
    b.optional :pattern
    b.wrapper :textfield, tag: 'div', class: 'mdc-text-field', error_class: 'mdc-text-field--invalid' do |ba|
      ba.use :icon
      ba.use :input, class: 'mdc-text-field__input'
      ba.use :label, class: 'mdc-floating-label'
      ba.wrapper tag: 'div', class: 'mdc-text-field__bottom-line' do
      end
    end
    b.use :hint, wrap_with: { tag: :p, class: 'mdc-text-field-helper-text mdc-text-field-helper-text--persistent' }
    b.use :error, wrap_with: { tag: :p, class: 'mdc-text-field-helper-text mdc-text-field-helper-text--validation-msg' }
  end

  config.wrappers :material_textarea, tag: 'div', class: 'input-group', error_class: 'is-invalid' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :textfield, tag: 'div', class: 'mdc-text-field mdc-text-field--textarea' do |ba|
      ba.use :input, class: 'mdc-text-field__input'
      ba.use :label, class: 'mdc-floating-label'
      ba.use :hint,  wrap_with: { tag: :span, class: :hint }
    end
    b.use :error, wrap_with: { tag: :p, class: 'mdc-text-field-helper-text mdc-text-field-helper-text--validation-msg' }
  end

  config.wrappers :nowrappers do |b|
    b.use :input
  end

  config.wrappers :material_file, tag: 'div', class: 'input-group', error_class: 'is-invalid' do |b|
    b.use :input
  end

  config.default_wrapper = :material
  config.wrapper_mappings = {
    check_boxes: :material_switch,
    boolean: :material_switch,
    text: :material_textarea,
    range: :material_slider_discrete,
    percentage: :material_slider_discrete,
    # select: :material_select,
    hidden: :nowrappers,
    file: :material_file
  }
end
