class ActivityLog < ApplicationRecord
  belongs_to :task

  validates :action, presence: true
end
