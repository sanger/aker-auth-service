class Users::SessionsController < Devise::SessionsController
  JWT_NBF_TIME = 60

  before_action :configure_sign_in_params, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:renew_jwt, :destroy]

  # POST /resource/sign_in
  def create
    # Append domain if only the username is entered
    if params.dig(:user, :email).present? && (params[:user][:email].exclude? "@")
      params[:user][:email] << "@sanger.ac.uk"
    end

    # Convert email to lowercase to prevent multiple accounts with same email
    if params.dig(:user, :email).present?
      params[:user][:email].downcase!
    end

    super

    session[:email] = current_user.email

    set_jwt_cookie(make_jwt(email: params[:user][:email], groups: current_user.groups))
  end

  # DELETE /resource/sign_out
  def destroy
    super
    cookies.delete :"aker_jwt_#{Rails.env}"
    session.destroy
  end

  def renew_jwt
    # Check session is valid
    # Renew JWT if so
    # Otherwise, unauthorized error

    if session[:email].present?
      jwt = make_jwt(email: session[:email], groups: User.find_by(email: session[:email]).groups)
      set_jwt_cookie(jwt)
      render body: jwt, status: :ok
    else
      # Session is not valid
      destroy
      head :unauthorized
    end
  end

  def default
  end

private

  def set_jwt_cookie(jwt)
    cookies[:"aker_jwt_#{Rails.env}"] = jwt
  end

  def make_jwt(data)
    iat = Time.now.to_i
    exp = iat + Rails.application.config.jwt_exp_time
    nbf = iat - JWT_NBF_TIME
    payload = { data: data, exp: exp, nbf: nbf, iat: iat }
    JWT.encode payload, Rails.application.config.jwt_secret_key, 'HS256'
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:redirect_to])
  end
end
