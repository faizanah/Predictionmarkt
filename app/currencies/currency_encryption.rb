require 'highline/import' if Rails.env.payment?

module CurrencyEncryption
  def self.included(base)
    base.extend ClassMethods
    base.initialize_encryption if Rails.env.test? || Rails.env.development?
  end

  module ClassMethods
    def initialize_encryption
      return if @initialized_encryption
      if Rails.env.test? || Rails.env.development?
        password = 'test-password'
      elsif Rails.env.payment?
        password = ask("Enter password: ") { |q| q.echo = false }
      else
        raise "No encryption is available"
      end
      SymmetricEncryption.cipher.key = Digest::SHA256.digest(password)
      @initialized_encryption = true
    end

    def encryption_test
      Rails.application.config_for('symmetric-encryption')['encryption_test']
    end

    def encryption_enc
      Rails.application.config_for('symmetric-encryption')['encryption_enc']
    end

    def validate_encryption
      d = SymmetricEncryption.decrypt(encryption_enc)
      return true if Digest::SHA256.hexdigest(d) == encryption_test
      raise 'encryption integrity is violated'
    end
  end

  def signing_key(address)
    creds = WalletCredentials.where(address: address).last!
    creds_to_key(creds)
  end

  def encrypt(data)
    encrypted = SymmetricEncryption.encrypt(data)
    raise unless data == SymmetricEncryption.decrypt(encrypted)
    encrypted
  end

  def decrypt(data)
    SymmetricEncryption.decrypt(data)
  end
end
