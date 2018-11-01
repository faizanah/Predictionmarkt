module MailerHelper
  def to_base64(file)
    Base64.encode64(File.read(Rails.root.join('app', 'assets', 'images', file))) if file.is_a?(String)
  end

  def attachment_url(name)
    return attachments[name].url if attachments[name]
    attach(name, attachments[name])
    attachments[name].url
  end

  def email_image_tag(name, html_args = {})
    image_tag asset_url(name, Rails.application.routes.default_url_options), html_args
  end
end
