class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
    
    
  private
    
     #метод предварительного фильтра для подтверждения входа пользователя
    def logged_in_user
        unless logged_in?
            store_location
            flash[:danger] = "Пожайлуста выполните вход"
            redirect_to login_url
        end
    end
end

