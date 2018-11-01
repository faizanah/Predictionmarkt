module SimpleForm
  module Components
    module Icons
      def icon(wrapper_options = nil)
        return if options[:icon].nil?
        options[:textfield_html] = { class: 'mdc-text-field--with-leading-icon mdc-text-field--box' }
        icon_class
      end

      def icon_class
        template.content_tag(:i, options[:icon], class: 'material-icons mdc-text-field__icon')
        # template.content_tag(:i, options[:icon], class: 'material-icons mdc-text-field__icon', tabindex: 0)
        # image_tag = content_tag(:i, options[:icon], class: 'material-icons')
        # template.content_tag(:span, image_tag, class: 'input-group-addon')
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::Icons)
