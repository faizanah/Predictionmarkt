# TODO: buggy history, still
# Need to subscribe to the history changes and force reload if there was an ajax call on the page
$(document).on 'click', '.ajaxable', (e) ->
  url = $(this).data('url')
  $.ajax
    type: 'GET'
    cache: false # prevents chrome history fuck-up
    url: url
    success: (res) ->
      window.history.replaceState(null, null, url)
    error: (res) ->
      window.location = url

$(document).on 'click', '.clickable', (e) ->
  url = $(this).data('url')
  window.location = url
