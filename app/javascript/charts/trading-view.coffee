require('charting_library/charting_library/charting_library.min.js')
import Datafeeds from 'charting_library/charting_library/datafeed/udf/datafeed.js'

$(document).on 'turbolinks:load', ->
  $.each $('.tv-chart'), (index, element) ->
    default_options = {
      fullscreen: false,
      autosize: true,
      symbol: $(element).data('tv-symbol'),
      toolbar_bg: '#FFF',
      container_id: element.id,
      datafeed: new Datafeeds.UDFCompatibleDatafeed("/api/charts"),
      library_path: "/assets/charting_library/",
      custom_css_url: $(element).data('tv-css'),
      enabled_features: [
        "dont_show_boolean_study_arguments",
        "header_screenshot",
        "remove_library_container_border",
      ]
      disabled_features: [
        # "header_widget_dom_node",
        # "control_bar"
        # "remove_library_container_border"
        "border_around_the_chart",
        "chart_property_page_scales",
        "header_resolutions",
        "header_symbol_search",
        "left_toolbar",
        "timeframes_toolbar",
        "use_localstorage_for_settings"
        "volume_force_overlay",
      ],

      # time_frames: [
      #   { text: "7D", resolution: "1D" },
      #   { text: "1D", resolution: "1D" },
      # ],

      # https://github.com/tradingview/charting_library/wiki/Overrides
      overrides: {
        "volumePaneSize": "medium"
        "scalesProperties.showLeftScale": false,
        # "scalesProperties.showSymbolLabels": true,
        # "scalesProperties.showSeriesPrevCloseValue": true,
        # "paneProperties.legendProperties.showSeriesOHLC": false,

        "mainSeriesProperties.style": 3,
        "mainSeriesProperties.areaStyle.color1": window.tc('primary-dark'),
        "mainSeriesProperties.areaStyle.color2": window.tc('primary'),
        "mainSeriesProperties.areaStyle.linecolor": window.tc('primary'),

        "mainSeriesProperties.showPriceLine": true,
        "mainSeriesProperties.priceLineWidth": 1,
        "mainSeriesProperties.priceAxisProperties.percentage": false,
        "mainSeriesProperties.priceAxisProperties.percentageDisabled": true
       },
      # debug: true,
    }
    tv_options = {}
    merged_options = $.merge(default_options, tv_options)
    widget = new (TradingView.widget)(merged_options)
    element.widget = widget
    # widget.onChartReady ->
    # widget.chart().setChartType(3)
