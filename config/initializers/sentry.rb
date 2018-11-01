unless Rails.env.test?
  Raven.configure do |config|
    config.dsn = 'https://9b1948684a234f429ba91a8ee118379d:55bd735ef08b471f8c25b691fa3ed29a@sentry.io/268861'
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end
end
