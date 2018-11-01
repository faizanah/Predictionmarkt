import Raven from 'raven-js'

ravenOptions =
  ignoreErrors: [
    'top.GLOBALS'
    'originalCreateNotification'
    'canvas.contentDocument'
    'MyApp_RemoveAllHighlights'
    'jigsaw is not defined'
    'ComboSearch is not defined'
    'atomicFindClose'
    'fb_xd_fragment'
    'bmi_SafeAddOnload'
    'EBCallBackMessageReceived'
    'conduitPage'
  ]
  ignoreUrls: [
    /graph\.facebook\.com/i
    /connect\.facebook\.net/i
    /extensions\//i
    /^chrome:\/\//i
    /metrics\.itunes\.apple\.com\.edgesuite\.net\//i
  ]

Raven
    .config('https://9b1948684a234f429ba91a8ee118379d@sentry.io/268861', ravenOptions)
    .install()


uid_element = document.querySelector("meta[name='uid']")

if uid_element
  Raven.setUserContext({id: uid_element.getAttribute("content")})
