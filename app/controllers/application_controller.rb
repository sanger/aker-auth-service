class ApplicationController < ActionController::Base
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  protect_from_forgery with: :exception

  before_action do
    RequestStore.store[:request_id] = request.request_id
  end

  helper_method :redirect_url
  def redirect_url
    if params[:redirect_url].present?
      # User is already signed in
      params[:redirect_url]
    elsif params.dig(:user, :redirect_to).present?
      # User has just signed in
      params[:user][:redirect_to]
    else
      nil
    end
  end

  def after_sign_in_path_for(resource)
    if redirect_url.present?
      # Suppress alert and notice flashes
      alert = nil
      notice = nil

      redirect_url
    else
      "/dashboard"
    end
  end

  def handle_unverified_request
    flash[:alert] = "It seems you've opened another Aker window, or had this one
    open for a long time, so your session has expired. Try again from this window."
    redirect_to request.referer
  end

end
