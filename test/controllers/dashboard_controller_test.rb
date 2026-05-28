# frozen_string_literal: true

require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @password = "password"
  end

  test "unauthenticated users cannot send a summary email" do
    post dashboard_summary_email_path

    assert_redirected_to login_path
  end

  test "sends a summary email and redirects to the dashboard" do
    sign_in_as(@user)

    assert_emails 1 do
      post dashboard_summary_email_path
    end

    assert_redirected_to dashboard_path
    assert_equal "Summary sent.", flash[:notice]
  end

  test "rejects sending a summary email when there are no tasks" do
    sign_in_as(@user)
    @user.tasks.destroy_all

    assert_no_emails do
      post dashboard_summary_email_path
    end

    assert_redirected_to dashboard_path
    assert_equal "There are no tasks to send.", flash[:alert]
  end

  test "clears pending tasks and keeps completed tasks" do
    sign_in_as(@user)

    assert_difference -> { @user.tasks.pending.count }, -1 do
      assert_no_difference -> { @user.tasks.completed.count } do
        delete dashboard_clear_pending_tasks_path
      end
    end

    assert_redirected_to dashboard_path
    assert_equal "Active list cleared.", flash[:notice]
    assert tasks(:one_completed).reload
  end

  test "rejects clearing pending tasks when there are none" do
    sign_in_as(@user)
    @user.tasks.pending.destroy_all

    assert_no_difference -> { Task.count } do
      delete dashboard_clear_pending_tasks_path
    end

    assert_redirected_to dashboard_path
    assert_equal "There are no active tasks to clear.", flash[:alert]
  end

  test "unauthenticated users cannot clear pending tasks" do
    delete dashboard_clear_pending_tasks_path

    assert_redirected_to login_path
  end

  private
    def sign_in_as(user)
      post login_path, params: {
        email: user.email,
        password: @password
      }
    end
end
