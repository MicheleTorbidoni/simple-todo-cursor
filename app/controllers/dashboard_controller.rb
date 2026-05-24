# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    tasks = Current.user.tasks

    render inertia: "Dashboard", props: {
      pending_tasks: tasks.pending.map { |task| serialize_task(task) },
      completed_tasks: tasks.completed.map { |task| serialize_task(task) }
    }
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
