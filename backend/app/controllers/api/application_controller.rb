class Api::ApplicationController < ActionController::Base
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  protect_from_forgery with: :exception,
                       prepend: true,
                       unless: :authenticated_with_bearer_token?

  def current_user
    return @current_user if defined?(@current_user)

    token_from_cookie = cookies[:auth_token] || cookies.signed[:auth_token]
    auth_key = bearer_auth_key
    auth_key ||= AuthKey.find_by(key: token_from_cookie) if token_from_cookie

    @current_user = auth_key&.user
  end

  def authenticate_user!
    render json: { error: "Not authorized" }, status: :unauthorized unless current_user
  end

  def csrf_token
    render json: { csrf_token: form_authenticity_token }
  end

  private

  def bearer_token
    request.headers["Authorization"]&.match(/\ABearer\s+(.+)\z/)&.captures&.first
  end

  def bearer_auth_key
    return @bearer_auth_key if defined?(@bearer_auth_key)

    @bearer_auth_key = bearer_token.present? ? AuthKey.find_by(key: bearer_token) : nil
  end

  def authenticated_with_bearer_token?
    bearer_auth_key.present?
  end
end
