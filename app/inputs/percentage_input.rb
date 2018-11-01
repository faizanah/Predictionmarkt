class PercentageInput < SimpleForm::Inputs::Base
  def input(_wrapper_options = nil)
    setup_dom
    out = ActiveSupport::SafeBuffer.new
    out << build_hidden_field
    out << build_text_field
    out
  end

  private

    def build_hidden_field
      args = { min: hidden_field_step,
               max: hidden_field_max,
               step: hidden_field_step }
      @builder.hidden_field(attribute_name, args).html_safe
    end

    def build_text_field
      args = { as: :numeric, wrapper: 'material',
               label: options[:label],
               label_html: { class: 'mdc-floating-label--float-above' },
               input_html: { min: text_field_step,
                             max: text_field_max,
                             step: text_field_step } }
      @builder.input(text_field_name, args).html_safe
    end

    def setup_dom
      options[:slider_html] = slider_html
      options[:slider_html].merge!(slider_html_for_dependent)
      options[:track_html] = { style: "transform: scaleX(#{pct});" }
      # Don't move, symbol / str collision
      options[:slider_html][:class] = ['mdc-slider-pmkt-percentage', 'mdc-slider']
    end

    # Dom

    def slider_html
      { "aria-label"    => "Select Percentage",
        "aria-valuemin" => 0,
        "aria-valuemax" => 100,
        "aria-valuenow" => 100 * pct,

        'data-text-target' => "##{object_name}_#{text_field_name}",
        'data-hidden-target' => "##{object_name}_#{attribute_name}",
        'data-hidden-multiplier' => text_to_hidden_rate,

        'id' => "#{object_name}_#{attribute_name}_slider",

        "role" => "slider" }
    end

    def slider_html_for_dependent
      return {} unless options[:js_dependency]
      o = object.send(options[:js_dependency])
      { 'data-dependent-target' => "##{object_name}_text_#{o[:target]}",
        'data-dependent-balance' => o[:balance] }
    end

    # Option parsing is done in 2 stages:
    # 1) The form object is checked for attr_max / attr_step, etc
    # 2) If methods don't exist - inline options are parsed
    # TODO: remove inline options parsing

    def fetch_options(what, attr_name, default = nil)
      name = [attr_name, what].join('_')
      return object.send(name) if object.respond_to?(name)
      fetched = options[name.to_sym] || default
      raise "undefined #{name}" unless fetched
      fetched
    end

    def text_field_name
      "text_#{attribute_name}"
    end

    def text_field_step
      fetch_options('step', text_field_name, 1)
    end

    # TODO: fix this shit
    def text_field_max
      return nil unless hidden_field_max
      hidden_field_max.divmod(hidden_field_step).first * text_field_step
      # fetch_options('max', text_field_name) # default)
    end

    def hidden_field_step
      fetch_options('step', attribute_name, 1)
    end

    def text_to_hidden_rate
      # text_field_step.to_d / hidden_field_step
      hidden_field_step / text_field_step.to_d
    end

    def hidden_field_max
      fetch_options('max', attribute_name)
    end

    def hidden_field_val
      object.send(attribute_name)
    end

    def pct
      return 0 if hidden_field_val.to_d.zero?
      hidden_field_val.to_d / hidden_field_max
    end
end
