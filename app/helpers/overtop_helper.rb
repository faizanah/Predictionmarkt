module OvertopHelper
  # https://github.com/resivalex/rails-bootstrap-tabs
  class CardTopRendererRenderer < RailsBootstrapTabs::Renderers::TabsBootstrap4Renderer
    def initialize(args)
      super
      @options[:content_class] ||= 'ot-container__content'
    end

    def render_tabs_wrapper
      content_tag 'div', class: 'ot-container__header' do
        content_tag :ul, class: 'ot-container__header-tabs nav navbar navbar-dark' do # nav is needed by bootstrap js
          yield
        end
      end
    end
  end

  def ot_tabs(args = {}, &block)
    tabs = CardTopRendererRenderer.new(self, &block).render
    content_tag('div', tabs, class: 'ot-container') do
      capture do
        concat tabs
        concat content_tag(:div, social_links, class: 'ot-container__footer') if args[:social]
        concat content_tag(:div, render(args[:footer]), class: 'ot-container__footer') if args[:footer]
      end
    end
  end

  def ot_container(title, args = {}, &block)
    args[:title] = title
    block_content = capture(&block)
    content_tag 'div', class: 'ot-container' do
      capture do
        concat content_tag 'div', ot_container_header(args), class: 'ot-container__header'
        concat content_tag 'div', block_content, class: 'ot-container__content'
      end
    end
  end

  def ot_container_header(args)
    capture do
      concat content_tag('section', content_tag('h5', args[:title]), class: 'ot-container__title')
      concat currency_menu(args.merge(menu_class: "currency-menu--darkbg")) if args[:currencies]
    end
  end
end
