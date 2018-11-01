namespace :errors do
  def scan_for_authenticity_token(part)
    if part =~ /token/
      pos = part =~ /token/
      puts part[[pos - 500, 0].max..[pos + 500, part.length].min]
      raise 'There is authenticity token in the HTML!!!!'
    end
    part
  end

  def generate(error)
    create_localized_errors(error)
    update_default_error(error)
  end

  def error_path(error, locale)
    Rails.root.join("public/errors/#{error}.#{locale}.html")
  end

  def create_localized_errors(error)
    [[:en, 'predictionmarkt.com']].each do |locale, host|
      _, _, body = ErrorsController.action("render_error").call('rack.input' => StringIO.new(''),
                                                                'REQUEST_METHOD' => 'GET',
                                                                'HTTP_ERROR_CODE' => error,
                                                                'HTTP_HOST' => host)
      File.open(error_path(error, locale), 'w') do |f|
        body.each { |part| f.write scan_for_authenticity_token(part) }
      end
    end
  end

  def update_default_error(error, locale = 'en')
    default_error_path = Rails.root.join("public/#{error}.html")
    FileUtils.copy error_path(error, locale), default_error_path
  end

  ERRORS = %w[403 404 422 500 502 503].freeze

  ERRORS.each do |error|
    task error.to_sym => :environment do
      generate error
    end
  end

  task all: ERRORS.map(&:to_sym)
end
