# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_task, only: %i[ update destroy ]

  def create
    task = Current.user.tasks.build(task_params)

    if task.save
      redirect_to dashboard_path
    else
      redirect_back fallback_location: dashboard_path,
                    inertia: { errors: task.errors.to_hash(true).transform_values(&:first) }
    end
  end

  def update
    if @task.update(task_params)
      redirect_to dashboard_path
    else
      redirect_back fallback_location: dashboard_path,
                    inertia: { errors: @task.errors.to_hash(true).transform_values(&:first) }
    end
  end

  def destroy
    @task.destroy
    redirect_to dashboard_path
  end

  private
    def set_task
      @task = Current.user.tasks.find(params[:id])
    end

    def task_params
      params.permit(:name, :completed)
    end
end
