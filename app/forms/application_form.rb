class ApplicationForm
  include ActiveModel::Model
  extend ActiveModel::Callbacks
  include ActiveModel::Validations::Callbacks

  define_model_callbacks :save, :initialize

  include Rails.application.routes.url_helpers
  include Rails.application.routes.mounted_helpers

  cattr_accessor :corruptible_attributes

  def initialize(*attrs)
    run_callbacks :initialize do
      super
    end
  end

  def id
    nil
  end

  def persisted?
    false
  end

  def corrupted?
    return false unless corruptible_attributes
    return false if valid?
    corruptible_attributes.any? { |a| errors.key?(a) }
  end

  def save
    run_callbacks :save do
      if valid?(:save)
        persist!
      else
        false
      end
    end
  end

  def self.validates_corruptible(*attrs)
    self.corruptible_attributes ||= []
    attrs.each { |a| self.corruptible_attributes << a }
  end

  protected

    def persist!; end
end
