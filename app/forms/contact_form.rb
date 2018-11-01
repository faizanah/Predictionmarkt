class ContactForm < ApplicationForm
  attr_accessor :name, :email, :subject, :message

  validates_presence_of :email
  validates_presence_of :name
  validates_presence_of :message
  validates_format_of :email, with: /@/
end
