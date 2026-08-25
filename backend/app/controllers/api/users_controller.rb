class Api::UsersController < Api::ApplicationController
  skip_forgery_protection only: [ :login, :register ]

  def login
    user = User.find_by(username: params[:username])
    if !user || !user.authenticate(params[:password])
      return render json: { error: "Wrong email or password" }, status: :unauthorized
    end

    auth_key = user.generate_auth_key

    response.set_cookie(:auth_token, {
      value: auth_key.key,
      httponly: true,
      expires: 2.weeks.from_now,
      path: "/",
      same_site: :lax,
      secure: Rails.env.production?
    })

    render json: authenticated_user_response(user, auth_key), status: :ok
  end

  def is_logged_in
    if current_user
      render json: { authenticated: true, user: render_user(current_user), csrf_token: form_authenticity_token }, status: :ok
    else
      render json: { authenticated: false, csrf_token: form_authenticity_token }, status: :ok
    end
  end

  def logout
    auth_record = bearer_auth_key || AuthKey.find_by(key: cookies[:auth_token])
    auth_record&.destroy

    response.delete_cookie(:auth_token, {
      path: "/",
      same_site: :lax,
      secure: Rails.env.production?
    })

    head(:ok)
  end

  def register
    if User.find_by(username: params[:username]) || User.find_by(email: params[:email])
      return render json: { error: "User already exists" }, status: :conflict
    end
    user = User.create(username: params[:username], email: params[:email], password: params[:password])
    auth_key = user.generate_auth_key

    response.set_cookie(:auth_token, {
      value: auth_key.key,
      httponly: true,
      expires: 2.weeks.from_now,
      path: "/",
      same_site: :lax,
      secure: Rails.env.production?
    })

    render json: authenticated_user_response(user, auth_key), status: :created
  end

  private

  def render_user(user)
    {
      username: user.username
    }
  end

  def authenticated_user_response(user, auth_key)
    {
      **render_user(user),
      auth_token: auth_key.key,
      csrf_token: form_authenticity_token
    }
  end
end
