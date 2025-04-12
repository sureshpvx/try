class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create google_oauth2 ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }
  skip_before_action :require_authentication, only: [:new, :create, :google_oauth2]

  def new
  end

  def create
    user = User.find_by(email_address: params[:email_address])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in successfully"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Signed out successfully"
  end

  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      # Set session[:user_id] so that it persists across requests
      session[:user_id] = @user.id
      
      # Set Current.session to the user (you can adjust this based on your setup)
      Current.session = @user
  
      # Redirect to the root page after successful login
      redirect_to root_path
    else
      redirect_to root_path, alert: "Could not authenticate."
    end
  end  
end