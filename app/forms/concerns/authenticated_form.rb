module AuthenticatedForm
  extend ActiveSupport::Concern

  included do
    attr_accessor :user
    validates_presence_of :user
  end
end
