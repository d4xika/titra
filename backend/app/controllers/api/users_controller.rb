class Api::UsersController < Api::ApplicationController
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
      path: '/',
      same_site: :lax,
      secure: Rails.env.production?
    })

    return render json: authenticated_user_response(user), status: :ok
  end

  def is_logged_in
    if current_user
      render json: { authenticated: true, user: render_user(current_user), csrf_token: form_authenticity_token }, status: :ok
    else
      render json: { authenticated: false, csrf_token: form_authenticity_token }, status: :ok
    end
  end

  def logout
    token = cookies[:auth_token]

    if token
      auth_record = AuthKey.find_by(key: token)
      auth_record.destroy if auth_record
    end

    response.delete_cookie(:auth_token, {
      path: '/',
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
      path: '/',
      same_site: :lax,
      secure: Rails.env.production?
    })

    return render json: authenticated_user_response(user), status: :created
  end

  private

  def render_user(user)
    return {
      username: user.username
    }
  end

  def authenticated_user_response(user)
    {
      **render_user(user),
      csrf_token: form_authenticity_token
    }
  end
end
