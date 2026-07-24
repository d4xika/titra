class Api::ProjectsController < Api::ApplicationController
  before_action :authenticate_user!

  def index
    if params[:name].present?
      @project = current_user.projects.find_by(name: params[:name])
      return render json: @project, status: :ok
    end

    @projects = current_user.projects
    return render json: @projects, status: :ok
  end

  def show
    @project = current_user.projects.find_by(name: params[:name]) || current_user.projects.find_by(id: params[:name])

    if @project
      return render json: @project, status: :ok
    else
      return render json: { error: "Project not found" }, status: :not_found
    end
  end

  def create
    @project = current_user.projects.new(project_params)

    if @project.save
      return render json: @project, status: :created
    else
      return render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @project = current_user.projects.find_by(id: params[:name]) || current_user.projects.find_by(name: params[:name])

    if @project.update(name: params[:project][:name])
      return render json: @project, status: :ok
    else
      return render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @project = current_user.projects.find_by(id: params[:name]) || current_user.projects.find_by(name: params[:name])
    @project.destroy
    head :no_content
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end
end
