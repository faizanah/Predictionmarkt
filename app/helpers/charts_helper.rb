module ChartsHelper

  # TODO http://www.marinamele.com/2014/04/google-charts-double-axes.htmlhttp://www.marinamele.com/2014/04/google-charts-double-axes.html

  def pmkt_line_chart(data, name = 'chart', args = {})
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('date', 'Date' )
    data_table.new_column('number', 'Price', 0..100)
    data.each do |date, stats|
      data_table.add_row([date.to_date, stats.median ? (stats.median.to_d / @contract.settle_price * 100).round(2) : nil])
    end
    #option = { width: "100%", height: 240, title: 'Company Performance', material: false, format: "#", gridlines: {count: 14}, vAxis: { viewWindow: { max: 1, min: 0}}, displayAnnotations: true}
    # option = { width: "100%", height: 240, title: 'Company Performance', material: true, format: "#", gridlines: {count: 14}, axes: { y: {max: 1, min: 0}}}
    #
    option = { width: "100%", height: 240, vAxis: { viewWindow: { max: 100, min: 0}},  hAxis: {format:'MMM d',  },
               pointSize: 6,
               hAxis: {minValue: data.keys.first.to_date,
                       maxValue: data.keys.last.to_date},

       vAxis: {minValue: 0,
                       maxValue: 100,
                       format: '#\'%\''}}


    chart = GoogleVisualr::Interactive::LineChart.new(data_table, option)
#       vAxis: {minValue: 0,
#                       maxValue: 100,
#                       format: '#\'%\''}}


    # chart = GoogleVisualr::Interactive::AnnotationChart.new(data_table, option)
    element_id = "chart-#{name}"
    if args[:js]
      r = chart.load_js(element_id) + chart.draw_js(element_id)
      rendered = javascript_tag("$(\"a[href='##{name}']\").on('shown.bs.tab', function (e) { #{r} })")
      rendered += javascript_tag("$('##{element_id}')[0].style.height = '240px'")
    else
      rendered = render_chart(chart, element_id)
    end
    content_tag('div', '', id: element_id) + rendered
  end


  # Visualization is broken
  # Candlestick vs CandlestickChart in the google.charts. call
  def pmkt_candlestick_chart(data, name = 'chart-1')
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('date', 'Date' )
    data_table.new_column('number', 'Odds')
    data_table.new_column('number', 'Odds')
    data_table.new_column('number', 'Odds')
    data_table.new_column('number', 'Odds')
    data.each do |date, stats|
      data_table.add_row([date.to_date, stats.min, stats.value_from_percentile(30), stats.value_from_percentile(70), stats.max])
    end
    option = { width: "100%", height: 240, title: 'Company Performance', material: true}
    chart = GoogleVisualr::Interactive::CandlestickChart.new(data_table, option)
    content_tag('div', render_chart(chart, "chart-#{name}"), id: "chart-#{name}")
  end

end
