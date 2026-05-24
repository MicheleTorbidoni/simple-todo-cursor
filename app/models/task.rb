# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user

  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true, length: { maximum: 255 }

  scope :pending, -> { where(completed: false).order(created_at: :desc) }
  scope :completed, -> { where(completed: true).order(updated_at: :desc) }
end
