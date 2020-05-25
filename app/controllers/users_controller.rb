class UsersController < ApplicationController 
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy]  #предварительный фильтр для загрузки информции до загрузки контроллера
  before_action :correct_user, only: [:edit, :update]  #предварительный фильтр для того, чтобы свою страницу могли редактировать только зарегистрированные пользователи
  before_action :admin_user, only: :destroy
   
    
  def destroy
      User.find(params[:id]).destroy
      flash[:success] = "Минус один сладкий, у нас потери!"
      redirect_to users_url
  end
    
  def index
      @users = User.paginate(page: params[:page], per_page: 30)
  end
    
  def new
      @user = User.new
  end
    
  def show
      @user = User.find(params[:id])
      @microposts = @user.microposts.paginate(page: params[:page])
  end
    
  def create
      @user = User.new(user_params)
      if @user.save
          @user.send_activation_email
          flash[:info] = "Уважаемый, проверька свою почту, чтобы подтвердить аккаунт."
          redirect_to root_url
      else
          render 'new'
      end
  end
    
    def edit
        @user= User.find(params[:id])
    end
    
    def update
        @user= User.find(params[:id])
        if @user.update_attributes(user_params)
            #обработать успешное изменение.
            flash[:success] = "Сладенький, твой профиль обновлен"
            redirect_to @user
        else 
            render 'edit'
        end
    end
    
    private
    
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    
    #подтверждение прав пользователя владения своей страницей
    def correct_user
        @user = User.find(params[:id])
        redirect_to(root_url) unless current_user?(@user)
    end
    
    #подтверждает наличие администраторскиъ привилегий
    def admin_user
        redirect_to(root_url) unless current_user.admin?
    end
end
