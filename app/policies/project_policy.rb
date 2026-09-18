class ProjectPolicy < ApplicationPolicy
  def show?
    user.admin? || record.user == user
  end
  
  def update?
    user.admin? || record.user == user
  end

  def destroy?
    user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        scope.where(user: user)
      end
    end
  end

end