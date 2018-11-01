window.dataLayer = window.dataLayer || []

gtag = ->
  dataLayer.push arguments
  return

gtag('js', new Date())

$(document).on 'turbolinks:load', ->
  if typeof gtag is 'function'
    gtag('config', 'UA-113929701-1', {'page_path': window.location.pathname})
    uid_element = document.querySelector("meta[name='uid']")
    if uid_element
      gtag('set', {'user_id': uid_element.getAttribute("content") })
