# frozen_string_literal: true

require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @password = "password"
    @task = tasks(:one_pending)
    @other_task = tasks(:two_pending)
  end

  test "unauthenticated users cannot create tasks" do
    assert_no_difference -> { Task.count } do
      post tasks_path, params: { name: "Unauthorized task" }
    end

    assert_redirected_to login_path
  end

  test "creates a task and redirects to the dashboard" do
    sign_in_as(@user)

    assert_difference -> { @user.tasks.count }, 1 do
      post tasks_path, params: { name: "New task" }
    end

    assert_redirected_to dashboard_path
    assert_equal "New task", @user.tasks.order(:created_at).last.name
  end

  test "rejects creating a task with a blank name" do
    sign_in_as(@user)

    assert_no_difference -> { Task.count } do
      post tasks_path, params: { name: "   " }
    end

    assert_response :redirect
  end

  test "updates a task name" do
    sign_in_as(@user)

    patch task_path(@task), params: { name: "Updated task" }

    assert_redirected_to dashboard_path
    assert_equal "Updated task", @task.reload.name
  end

  test "toggles task completion" do
    sign_in_as(@user)

    patch task_path(@task), params: { completed: true }

    assert_redirected_to dashboard_path
    assert @task.reload.completed?

    patch task_path(@task), params: { completed: false }

    assert_redirected_to dashboard_path
    assert_not @task.reload.completed?
  end

  test "destroys a task" do
    sign_in_as(@user)

    assert_difference -> { Task.count }, -1 do
      delete task_path(@task)
    end

    assert_redirected_to dashboard_path
  end

  test "cannot access another user's task" do
    sign_in_as(@user)

    patch task_path(@other_task), params: { name: "Hacked" }

    assert_response :not_found
  end

  private
    def sign_in_as(user)
      post login_path, params: {
        email: user.email,
        password: @password
      }
    end
end
