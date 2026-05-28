# frozen_string_literal: true

class TasksMailer < ApplicationMailer
  def summary(user, pending_tasks, completed_tasks)
    @user = user
    @pending_tasks = pending_tasks
    @completed_tasks = completed_tasks

    mail subject: "Your task summary", to: user.email
  end
end
