import URI from 'urijs'

# https://stackoverflow.com/questions/4068373/center-a-popup-window-on-screen
PopupCenter = (url, title, w, h) ->
  # Fixes dual-screen position                              Most browsers      Firefox
  dualScreenLeft = if window.screenLeft != undefined then window.screenLeft else screen.left
  dualScreenTop = if window.screenTop != undefined then window.screenTop else screen.top

  width = if window.innerWidth then window.innerWidth else if document.documentElement.clientWidth then document.documentElement.clientWidth else screen.width
  height = if window.innerHeight then window.innerHeight else if document.documentElement.clientHeight then document.documentElement.clientHeight else screen.height

  left = width / 2 - (w / 2) + dualScreenLeft
  top = height / 2 - (h / 2) + dualScreenTop

  newWindow = window.open(url, title, 'toolbar=0,status=0,scrollbars=yes, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left)
  if window.focus
    newWindow.focus()

$(document).on 'turbolinks:load', ->
  $.each $('.sb__link'), (index, element) ->
    $(element).bind 'click', (e) ->
      e.preventDefault()
      sb = $(this).data('sb')

      switch sb['target']
        when 'facebook'
          url = new URI('//www.facebook.com/dialog/share?')
          fb_app_id = $("#fb-root").data('app-id')
          url.addQuery(app_id: fb_app_id, display: 'popup', link: sb['url'], href: sb['url'])
          height = 600
          width  = 600
        when 'twitter'
          url = new URI('//twitter.com/share?')
          url.addQuery(text: sb['title'], url: sb['url'], via: 'predictionmarkt' )
          height = 300
          width  = 600
        when 'google'
          url = new URI('//plus.google.com/share?')
          url.addQuery(url: sb['url'] )
          height = 600
          width  = 600

      PopupCenter(url, '', width, height)
