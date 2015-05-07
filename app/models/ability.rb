class Ability
    include CanCan::Ability

    def initialize(user)
        @user = user || User.new #for guest
        can [:update, :edit], User do |l_user|
            user.id == @user.id
        end
        @user.roles.each { |role| send(role.name) }

#    can :assign_roles, User if user.admin?
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end

  def admin
    can :manage, :all
    can :assign_roles, User
  end

  def organizer
    can :manage, Event do |event|
        (event.try(:id) == @event.user_id) || event.new_record?
    end
  end

  def member

  end

  def banned

  end

end