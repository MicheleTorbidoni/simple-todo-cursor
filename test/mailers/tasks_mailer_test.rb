# frozen_string_literal: true

require "test_helper"

class TasksMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:one)
    @pending_tasks = [ tasks(:one_pending) ]
    @completed_tasks = [ tasks(:one_completed) ]
  end

  test "summary email is sent to the user with task sections" do
    email = TasksMailer.summary(@user, @pending_tasks, @completed_tasks)

    assert_equal [ @user.email ], email.to
    assert_equal "Your task summary", email.subject

    body = email.body.encoded
    assert_includes body, "Buy groceries"
    assert_includes body, "Read email"
    assert_includes body, "Active tasks"
    assert_includes body, "Completed tasks"
  end
end
