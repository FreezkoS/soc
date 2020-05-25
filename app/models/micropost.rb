class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true #наличие идентификатора пользователя
  validates :content, presence: true, length: {maximum: 140}
  validate :picture_size
    
  private
    
    #проверяем размер выгруженного изображения
    def picture_size
        if picture.size > 5.megabytes
            errors.add(:picture, "Загрузите файл меньше 5 мб")
        end
    end
end
