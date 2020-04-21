module SessionsHelper
    def log_in(user) #запоминание сеанса пользователя, то есть - осуществляет вход
        session[:user_id] = user.id
    end
    
    #запоминание пользователя в постоянном сеансе
    def remember(user)
        user.remember
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end
    
    #возвращает true, если данный пользователь явялется текущим
    def current_user?(user)
        user == current_user
    end
    
    def current_user #возвращает текущего наедшео пользователя, соответсвующего токену в cookie
      if (user_id = session[:user_id])
        @current_user ||= User.find_by(id: session[:user_id])
      elsif (user_id = cookies.signed[:user_id])
        user = User.find_by(id: user_id)
        if user && user.authenticated?(:remember, cookies[:remember_token])
          log_in user
          @current_user = user
        end
      end
    end   
    
    def logged_in? #вернет true если пользователь есть, ну или найден
        !current_user.nil?
    end
    
    #закрываем сеанс
    def forget(user)
        user.forget #метод, который вызываем из модели User
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end
    
    def log_out #удаление сессии при использовании метода destroy
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end
    
    #Перенаправить по сохраненному адресу или на страницу по умолчанию
    def redirect_back_or(default)
        redirect_to(session[:forwarding_url] || default)
        session.delete(:forwarding_url)
    end
    
    #Запоминание URL
    def store_location
        session[:forwarding_url] = request.url if request.get?
    end
end
