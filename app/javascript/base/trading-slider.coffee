import Big from 'big.js/big'

window.initializeMarketForm = () ->
  # Need to re-init the theme for the ajax / partial updates
  window.initTheme()

  $.each $('.mdc-slider-pmkt-percentage'), (index, element) ->
    # This slider acts as a percentage selector for the text target
    # Text target is numeric with value in 0..maximum range, used as a friendly attribute for the user to manage
    # Hidden target is an integer with value in 0..maximum * rate, actually used for the form submission
    #
    # Total amount: 10 usd, 1000 cents
    # text field: 5 usd
    # hidden field 500 cents
    # slider 50%

    text_target = $(element.getAttribute('data-text-target'))

    hidden_target = $(element.getAttribute('data-hidden-target'))
    hidden_multiplier = element.getAttribute('data-hidden-multiplier')

    dependent_target = $(element.getAttribute('data-dependent-target'))
    dependent_balance = element.getAttribute('data-dependent-balance')

    element.slider.listen 'MDCSlider:input', () ->
      digits = text_target[0].step.toString().length - 2
      digits = 0 if Number(text_target[0].step) == 1
      return unless text_target[0].max
      val = Big(text_target[0].max).times(element.slider.value).div(100).toFixed(digits)
      text_target.val(val)

    text_target.bind 'input', () ->
      digits = text_target[0].step.toString().length - 2
      slider_value = text_target.val() / text_target[0].max * 100
      element.slider.value = slider_value

    text_target.bind 'change', () ->
      hidden_value = Big(text_target.val()).times(hidden_multiplier).toFixed(0)
      hidden_target.val(hidden_value)
      return unless dependent_target.length
      max = Number(dependent_balance / text_target.val()).toFixed(0)
      dependent_target[0].max = max
      dependent_target.val(max) if Number(dependent_target.val()) > max
      dependent_target.trigger('input').trigger('change')

    element.slider.listen 'MDCSlider:change', () ->
      text_target.trigger('change').focus().blur() # focus/blur required for removing validation errors

  $('#new_trading_order_form').bind 'change', () ->
    return unless window.initThemeComplete # This is required since datepicker triggers change after ajax request
    form = $('#new_trading_order_form')
    url = form.data('preview')
    $.ajax
      type: 'PUT'
      cache: false # prevents chrome history fuck-up
      url: url
      data: form.serialize()

$(document).on 'turbolinks:load', ->
  window.initializeMarketForm()
