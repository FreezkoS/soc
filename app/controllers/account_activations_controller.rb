class AccountActivationsController < ApplicationController
    def edit
        user = User.find_by(email: params[:email])
        if user && !user.activated? && user.authenticated?(:activation, params[:id])
            user.activate
            log_in user
            flash[:success] = "Аккаунт активирован!"
            redirect_to user
        else
            flash[:danger] = "Активация аккаунта невыполнена!"
            redirect_to root_url
        end
    end
end
