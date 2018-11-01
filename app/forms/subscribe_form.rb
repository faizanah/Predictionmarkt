class SubscribeForm < ApplicationForm
  attr_accessor :email, :blog_post_id

  validates_presence_of :email
  validates_format_of :email, with: /@/

  def persist!
    AdminMailer.debug(message: 'Blog Subscribe', email: email).deliver
    true
  end
end
