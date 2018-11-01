# tc = "theme color" - fetches CSS colors from the root html element
window.tc = (color)->
  computed_style = window.getComputedStyle(document.querySelector("html"))
  fetched_color = computed_style.getPropertyValue('--mdc-theme-' + color)
  if fetched_color == ''
    console.error('failed to fetch color: ' + color)
  return fetched_color.trim()
