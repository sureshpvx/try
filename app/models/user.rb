class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :provider, presence: true, if: -> { uid.present? }
  validates :uid, presence: true, if: -> { provider.present? }

  def self.from_omniauth(auth)
    Rails.logger.info "Processing OAuth data: #{auth.inspect}"
    
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email_address = auth.info.email
    user.name = auth.info.name
    user.image_url = auth.info.image
    
    # Only set password for new users
    if user.new_record?
      user.password = SecureRandom.hex(16)
      user.password_confirmation = user.password
    end
    
    Rails.logger.info "User after processing: #{user.inspect}"
    user
  end
end
