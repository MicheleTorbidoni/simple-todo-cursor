# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/tasks_mailer
class TasksMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/tasks_mailer/summary
  def summary
    user = User.first
    tasks = user.tasks

    TasksMailer.summary(user, tasks.pending, tasks.completed)
  end
end
