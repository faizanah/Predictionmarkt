import autosize from 'autosize'
$(document).on 'turbolinks:load', ->
  autosize $('textarea')
