# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.present?
      can :create, Board
      can :read, Board, public: true
      can :read, Board, memberships: { user_id: user.id }
      can :manage, Board, memberships: { user_id: user.id, admin: true }
      can :manage, Column, board: { memberships: { user_id: user.id } }
      can :manage, Card, column: { board: { memberships: { user_id: user.id } } }
      can :manage, Comment, user: { id: user.id }
      can :read, Comment, user: { id: user.id }
      can :manage, Comment, card: { column: { board: { memberships: { user_id: user.id, admin: true } } } }
    end
  end
end
