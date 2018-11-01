class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  layout 'mailer'

  default from: 'PredictionMarkt <concierge@predictionmarkt.com>',
          Auto_Submitted: 'auto-generated',
          Message_ID: -> { "<#{SecureRandom.uuid}@predictionmarkt.com>" }

  add_template_helper(ApplicationHelper)
  add_template_helper(MailerHelper)
  # add_template_helper(MailerHelper)

  # self.asset_host = nil

  helper_method :attach

  def attach(name, filename = nil)
    filename ||= name
    attachments.inline[name] = File.read(Rails.root.join('app', 'assets', 'images', filename))
  end
end
