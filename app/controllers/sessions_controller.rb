class SessionsController < ApplicationController
  def new
  end
    
  def create
      user = User.find_by(email: params[:session][:email].downcase) #извлечение информации о пользоваеле из БД на основе почты
      if user && user.authenticate(params[:session][:password]) #пользователь должен существовать и пароль ему соотвествует
          #осуществить вход пользователя и переадресовать на страницу профиля
          if user.activated?
          log_in user
          params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        #  remember user #вызов метода из модели User
          redirect_back_or user
          else
              message = "Активация аккаунта невыполнена!"
              message += "Проверьте вашу почту для активации аккаунта."
              flash[:warning] = message
              redirect_to root_url
          end
      else
          #создать сообщение об ошибке
      flash.now[:danger] = 'Почта или пароль не совпадают!'
      render 'new'
      end
  end
    
  def destroy
      log_out if logged_in?
      redirect_to root_url
  end
end
