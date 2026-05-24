# frozen_string_literal: true

require "test_helper"

class TaskTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @task = tasks(:one_pending)
  end

  test "is valid with a name" do
    task = Task.new(user: @user, name: "Write tests")

    assert task.valid?
  end

  test "is invalid without a name" do
    task = Task.new(user: @user, name: "")

    assert_not task.valid?
    assert_includes task.errors[:name], "can't be blank"
  end

  test "is invalid with a whitespace-only name" do
    task = Task.new(user: @user, name: "   ")

    assert_not task.valid?
    assert_includes task.errors[:name], "can't be blank"
  end

  test "is invalid when name exceeds 255 characters" do
    task = Task.new(user: @user, name: "a" * 256)

    assert_not task.valid?
    assert_includes task.errors[:name], "is too long (maximum is 255 characters)"
  end

  test "strips whitespace from the name" do
    task = Task.create!(user: @user, name: "  Trim me  ")

    assert_equal "Trim me", task.name
  end
end
