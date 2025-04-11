class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
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
    auth = request.env['omniauth.auth']
    Rails.logger.info "Auth data: #{auth.inspect}"
    
    user = User.from_omniauth(auth)
    Rails.logger.info "User after from_omniauth: #{user.inspect}"
    
    if user.save
      Rails.logger.info "User saved successfully"
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in with Google successfully"
    else
      Rails.logger.error "User save failed: #{user.errors.full_messages}"
      redirect_to sign_in_path, alert: "Authentication failed: #{user.errors.full_messages.join(', ')}"
    end
  end
end
