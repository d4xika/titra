class Api::SessionsController < Api::ApplicationController
  before_action :authenticate_user!

  def index
    @sessions = current_user.sessions.order(start_time: :desc)

    if params[:project_id].present?
      project = current_user.projects.find_by(id: params[:project_id]) || current_user.projects.find_by(name: params[:project_id])
      @sessions = @sessions.where(project_id: project&.id || params[:project_id])
    end

    if params[:time_window].present? && params[:time_window] != "ALL"

      ref_date = reference_date

      case params[:time_window]
      when "D"
        @sessions = @sessions.where(start_time: ref_date.beginning_of_day..ref_date.end_of_day)
      when "W"
        @sessions = @sessions.where(start_time: ref_date.beginning_of_week..ref_date.end_of_week)
      when "M"
        @sessions = @sessions.where(start_time: ref_date.beginning_of_month..ref_date.end_of_month)
      when "Y"
        @sessions = @sessions.where(start_time: ref_date.beginning_of_year..ref_date.end_of_year)
      end
    end

    limit = params[:limit].present? ? params[:limit].to_i : 10
    offset = params[:offset].present? ? params[:offset].to_i : 0

    @sessions = @sessions.limit(limit).offset(offset)

    return render json: @sessions, status: :ok
  end

  def create
    @session = current_user.sessions.new(session_params)

    if @session.save
      return render json: @session, status: :created
    else
      return render json: { errors: @session.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @session = find_session

    if @session.update(session_params)
      return render json: @session, status: :ok
    else
      return render json: { errors: @session.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @session = find_session
    @session.destroy
    head :no_content
  end

  def summary
    @sessions = current_user.sessions

    if params[:project_id].present?
      project = current_user.projects.find_by(id: params[:project_id]) || current_user.projects.find_by(name: params[:project_id])
      @sessions = @sessions.where(project_id: project&.id || params[:project_id])
    end

    if params[:time_window].present? && params[:time_window] != 'ALL'
      ref_date = reference_date

      case params[:time_window]
      when 'D'
        @sessions = @sessions.where(start_time: ref_date.beginning_of_day..ref_date.end_of_day)
      when 'W'
        @sessions = @sessions.where(start_time: ref_date.beginning_of_week..ref_date.end_of_week)
      when 'M'
        @sessions = @sessions.where(start_time: ref_date.beginning_of_month..ref_date.end_of_month)
      when 'Y'
        @sessions = @sessions.where(start_time: ref_date.beginning_of_year..ref_date.end_of_year)
      end
    end

    total_duration = @sessions.sum(:duration)

    return render json: { total_duration: total_duration }, status: :ok
  end

  private

  def reference_date
    ref_date = params[:date].present? ? Time.zone.parse(params[:date]) : Time.current
    offset = Integer(params[:timezone_offset], exception: false)

    return ref_date unless offset&.between?(-840, 840)

    Time.at(ref_date.to_f).getlocal(-offset * 60)
  end

  def find_session
    current_user.sessions.find(params[:id])
  end

  def session_params
    params.require(:session).permit(:start_time, :duration, :description, :project_id)
  end
end
