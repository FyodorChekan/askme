class User < ApplicationRecord
  has_secure_password

  has_many :questions, dependent: :delete_all

  before_save :downcase_nickname

  include Gravtastic
  gravtastic(secure: true, filetype: :png, size: 100, default: 'retro')

  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :nickname,
            presence: true,
            uniqueness: true,
            length: { maximum: 40 },
            format: { with: /\A\w+\Z/ }

  def downcase_nickname
    nickname.downcase!
  end  
end
