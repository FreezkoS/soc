class User < ApplicationRecord
    before_save { self.email = email.downcase } #перевод в нижний регистр
    validates :name, presence: true, length: {maximum: 50}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: {maximum: 255},
                      format: {with: VALID_EMAIL_REGEX},
                      uniqueness: {case_sensitive: false} #проверка уникальности для повторяющихся email
    
    has_secure_password
    validates :password, length: {minimum: 6}
end
