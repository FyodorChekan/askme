class UsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy show]
  before_action :authorize_user, only: %i[edit update destroy]

  def new
    session[:current_time] = Time.now
    @user = User.new
  end

  def create
    @user = User.new(user_params)
  
    if @user.save
      session[:user_id] = @user.id

      redirect_to root_path, notice: "Вы успешно зарегистрировались"
    else
      flash.now[:alert] = "Вы неправильно заполнили формы регистрации"

      render :new
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to root_path, notice: 'Данные пользователя обновлены'
    else
      flash.now[:alert] = 'При попытке сохранить пользователя возникли ошибки'
      render :edit
    end
  end

  def destroy
    @user.destroy
  
    session.delete(:user_id)
  
    redirect_to root_path, notice: 'Пользователь удалён'
  end  

  def show
    @questions = @user.questions.order(created_at: :desc)
    @question = Question.new(user: @user)
  end
  

  private

  def set_user
    @user = User.find(params[:id])
  end
  
  def authorize_user
    redirect_with_alert unless @user == current_user
  end  

  def user_params
    params.require(:user).permit(
      :name, :nickname, :email, :password, :password_confirmation
    )
  end
end
