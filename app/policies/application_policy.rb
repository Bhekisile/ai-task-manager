# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def create?
    true
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    private

    attr_reader :user, :scope
  end
end
