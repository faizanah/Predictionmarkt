# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |p|
  p.default_src :self
  p.form_action :self, '*.twitter.com'
  p.script_src  :self, '*.googletagmanager.com', '*.google-analytics.com', 'www.google.com/jsapi', :unsafe_inline, '*.facebook.net', '*.facebook.com *.twitter.com *.twimg.com'
  p.img_src     :self, :data, '*.google-analytics.com', '*.facebook.com', '*.twitter.com', '*.twimg.com'
  p.font_src    :self, :data # , 'fonts.gstatic.com'
  p.connect_src :self, 'sentry.io'
  p.object_src  :none
  p.frame_src   :self, '*.facebook.com *.twitter.com'
  p.style_src   :self, '*.twitter.com *.twimg.com', :unsafe_inline # , 'fonts.googleapis.com'

  # Specify URI for violation reports
  p.report_uri "https://sentry.io/api/268861/csp-report/?sentry_key=9b1948684a234f429ba91a8ee118379d"
end

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
