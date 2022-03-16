class SessionsController < ApplicationController
  def login
    if request.post?
      @user = User.find_by(login: params[:login])
      if @user&.authenticate(params[:password])
        reset_session
        session[:user_id] = @user.id
        redirect_to root_path
      else
        flash.now[:error] = 'Invalid login or password'
        render 'login', status: 422
      end
    end
  end

  def logout
    reset_session
    redirect_to login_path
  end
end
