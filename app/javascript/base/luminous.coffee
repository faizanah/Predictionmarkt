import { Luminous } from 'luminous-lightbox'

$(document).on 'turbolinks:load', ->
  $.each $('.md-zoomable-img'), (index, element) ->
    new Luminous(element)
