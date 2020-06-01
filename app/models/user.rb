class User < ApplicationRecord
    has_many :microposts, dependent: :destroy #связь с микропостами и удаление связующих с пользователем элементов
    has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
    has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
    
    has_many :following, through: :active_relationships, source: :followed
    has_many :followers, through: :passive_relationships, source: :follower
    
    attr_accessor :remember_token, :activation_token, :reset_token
    
    before_save :downcase_email #перевод в нижний регистр
    before_create :create_activation_digest
    
    validates :name, presence: true, length: {maximum: 50}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: {maximum: 255},
                      format: {with: VALID_EMAIL_REGEX},
                      uniqueness: {case_sensitive: false} #проверка уникальности для повторяющихся email
    
    has_secure_password
    validates :password, length: {minimum: 6}, allow_blank: true #воможность пароля быть пустым, для редактированиы
    
    #Возвращение дайджеста для указанной строки
    def User.digest(string)
      cost = ActiveModel::SecurePassword.min_cost ?
             BCrypt::Engine::MIN_COST :
             BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
    
    #Возвращения случайного токена
    def User.new_token
      SecureRandom.urlsafe_base64
    end
    
    #запоминание  пользователя в базе данных для использования в постоянных сеансах 
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token)) #обновление даджеста токена, т.к е имею доступ к паролю
    end
    
    #Возвращение true, если  указанный токен соотвествует дайджесту
    def authenticated?(attribute, token)
      digest = send("#{attribute}_digest")
      return false if digest.nil?
      BCrypt::Password.new(digest).is_password?(token)
    end
    
    #забываем пользователя при выходе
    def forget
        update_attribute(:remember_digest, nil)
    end
    
    def activate#активирует учетную запись
        update_attribute(:activated, true)
        update_attribute(:activated_at, Time.zone.now)
    end
    
    def send_activation_email #активирует учетную запись
        UserMailer.account_activation(self).deliver_now
    end
    
    #Устанавливает атрибуты для сброса пароля
    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest, User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
    end
    
    #Посылает письмо со ссылкой на форму ввода нового пароля
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end
    
    #возвращает true, если время для сброса пароля истекло
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end
    
    #определяем прото-ленту
    def feed
        following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
    end
    
    #Выполняем подписку на сообщения пользователя
    def follow(other_user)
        active_relationships.create(followed_id: other_user.id)
    end
    
    #отмена подписки на сообщения пользователя
    def unfollow(other_user)
        active_relationships.find_by(followed_id: other_user.id).destroy
    end
    
    #возвращает true, если текущий пользователь читает другого пользователя
    def following?(other_user)
        following.include?(other_user)
    end
    
    private
    
    def downcase_email #преобразование email в нижний регистр
      self.email = email.downcase 
    end
    
    #Создает и присваивает токен активации и его дайджест
    def create_activation_digest
        self.activation_token = User.new_token
        self.activation_digest = User.digest(activation_token)
    end
    
end
