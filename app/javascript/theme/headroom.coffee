import Headroom from 'headroom.js'
$(document).on 'turbolinks:load', ->
  $.each $("[data-headroom]"), (index, element) ->
    return true if element.headroom
    element.headroom = new Headroom(element)
    element.headroom.init()

