class ProjectPolicy < ApplicationPolicy
  def update?
    user.admin? || record.user == user
  end

  def destroy?
    user.admin?
  end
end