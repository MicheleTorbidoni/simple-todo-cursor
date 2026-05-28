# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    tasks = Current.user.tasks

    render inertia: "Dashboard", props: {
      pending_tasks: tasks.pending.map { |task| serialize_task(task) },
      completed_tasks: tasks.completed.map { |task| serialize_task(task) }
    }
  end

  def summary_email
    tasks = Current.user.tasks
    pending_tasks = tasks.pending.to_a
    completed_tasks = tasks.completed.to_a

    if pending_tasks.empty? && completed_tasks.empty?
      redirect_to dashboard_path, alert: "There are no tasks to send."
      return
    end

    TasksMailer.summary(Current.user, pending_tasks, completed_tasks).deliver_now

    redirect_to dashboard_path, notice: "Summary sent."
  end

  def clear_pending_tasks
    pending_tasks = Current.user.tasks.pending

    if pending_tasks.none?
      redirect_to dashboard_path, alert: "There are no active tasks to clear."
      return
    end

    pending_tasks.destroy_all

    redirect_to dashboard_path, notice: "Active list cleared."
  end

  private
    def serialize_task(task)
      {
        id: task.id,
        name: task.name,
        completed: task.completed
      }
    end
end
