class TaskPolicy < ApplicationPolicy
  def show?
    user.admin? || record.project.user == user
  end

  def update?
    user.admin? || record.project.user == user
  end

  def destroy?
    user.admin?
  end

  def complete?
    user.admin? || record.project.user == user
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        user.tasks
      end
    end
  end
end
