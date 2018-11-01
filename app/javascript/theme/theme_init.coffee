import {MDCCheckbox, MDCCheckboxFoundation} from '@material/checkbox'
import {MDCFormField, MDCFormFieldFoundation} from '@material/form-field'
import {MDCLinearProgress} from '@material/linear-progress'
import {MDCMenu, MDCMenuFoundation} from '@material/menu'
import {MDCRipple, MDCRippleFoundation, util} from '@material/ripple'
import {MDCSelect} from '@material/select'
import {MDCSlider} from '@material/slider'
import {MDCTabBar} from '@material/tabs'
import {MDCChip, MDCChipSet} from '@material/chips'
import {MDCTextField, MDCTextFieldFoundation} from '@material/textfield'
import {MDCToolbar, MDCToolbarFoundation} from '@material/toolbar'

#import mdcAutoInit from '@material/auto-init'
#mdcAutoInit.autoInit()

window.initTheme = () ->
  window.initThemeComplete = false

  $.each $('.daterange'), (index, element) ->
    return true if element.picker_initialized
    element.picker_initialized = true
    $(element).daterangepicker
      locale:
        format: 'YYYY-MM-DD'

  # Order is important
  $.each $('.mdc-text-field'), (index, element) ->
    element.textfield = MDCTextField.attachTo(element) unless element.textfield

  $.each $('.mdc-tab-bar'), (index, element) ->
    element.tabbar = MDCTabBar.attachTo(element) unless element.tabbar

  $.each $('.mdc-linear-progress'), (index, element) ->
    return true if element.linearProgress
    element.linearProgress = MDCLinearProgress.attachTo(element)
    element.linearProgress.progress = element.getAttribute('data-progress')
    if element.dataset.buffer
      element.linearProgress.buffer = element.getAttribute('data-buffer')

  # TODO: optimize
  $.each $('.btn-action'), (index, element) ->
    return true if element.ripple
    element.ripple = MDCRipple.attachTo(element)

  $.each $('.mdc-slider'), (index, element) ->
    return true if element.slider
    element.slider = MDCSlider.attachTo(element)

  $.each $('.mdc-toolbar'), (index, element) ->
    return true if element.toolbar
    element.toolbar = MDCToolbar.attachTo(element)

  $.each $('.mdc-select'), (index, element) ->
    return true if element.select
    element.select = MDCSelect.attachTo(element)
    #element.select.listen 'MDCSelect:change', () ->
    # alert(`Selected "${select.selectedOptions[0].textContent}" at index ${select.selectedIndex} ` + `with value "${select.value}"`)
    #
  $.each $('.mdc-chip-set'), (index, element) ->
    return true if element.chipset
    element.chipset = MDCChipSet.attachTo(element)

  $.each $('.mdc-menu-toggle'), (index, element) ->
    mdc_menu = $(element.getAttribute('data-toggle'))[0]
    return true if mdc_menu.menu
    mdc_menu.menu = MDCMenu.attachTo(mdc_menu)
    mdc_menu.menu.setAnchorCorner(MDCMenuFoundation.Corner.BOTTOM_START)
    $(element).bind 'click', (e) ->
      mdc_menu.menu.open = !mdc_menu.menu.open
      e.preventDefault()

  $.each $('.market-action-btn'), (index, element) ->
    return true if element.ripple
    element.ripple = MDCRipple.attachTo(element)

  $.each $('.btn-table-action'), (index, element) ->
    return true if element.ripple
    element.ripple = MDCRipple.attachTo(element)

  $('[data-toggle="tooltip"]').tooltip()

  window.initThemeComplete = true

$(document).on 'turbolinks:load', ->
  window.initTheme()
