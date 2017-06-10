# Rolypoly

[![Gem Version](https://badge.fury.io/rb/rolypoly.png)](http://badge.fury.io/rb/rolypoly)
[![Build Status](https://travis-ci.org/sportngin/rolypoly.png)](https://travis-ci.org/sportngin/rolypoly)

Allow certain roles access to certain controller actions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rolypoly'
```

And then execute:

```bash
$> bundle
```

## Custom Usage

```ruby
role_checker = Rolypoly.define_gatekeepers do
  allow(:super_duper_admin).to_all
  allow(:super_admin).on(:organization).to_all
  allow(:admin).on(:team).to_access(:show, :update)
end

role_checker_options = {
  organization: ['Organization', team.organization_id],
  team: team
}

role_checker.allow?(role_objects, :destroy, role_checker_options)
role_checker.allow?(role_objects, :destroy, role_checker_options)
```

## Policy Usage

```ruby
class TeamPolicy < Struct.new(:user, :team)

  include Rolypoly::RoleDSL

  allow(:super_duper_admin).to_all
  allow(:super_admin).on(:organization).to_all
  allow(:admin).on(:team).to_access(:show, :update)

  def show?
    allow?(:show)
  end

  def update?
    allow?(:update)
  end

  def destroy?
    allow?(:destroy)
  end

  def current_user_roles
    current_user.role_assignments
  end

  def rolypoly_resource_map
    {
      organization: ['Organization', team.organization_id]
      team: team
    }
  end

end
```

## Controller Usage

```ruby
class ApplicationController < ActionController::Base
  def current_user_roles
    current_user.roles
  end

  rescue_from(Rolypoly::FailedRoleCheckError) do
    render text: "Failed Authorization!", status: 401
  end
end

class UsersController < ApplicationController
  include Rolypoly::ControllerRoleDSL

  def index
    # ...
  end
  restrict(:index).to(:admin)
  # OR
  allow(:admin).to_access(:index)

  # Do a bunch at once
  allow(:scorekeeper, :official).to_access(:show, :score)
  def show
    # ...
  end

  def score
    # ...
  end

  # Allow admin role to access all actions of this controller
  allow(:admin).to_all

  # Make action public
  restrict(:landing).to_none
  # OR
  publicize :landing

  def landing
    # ...
  end

  # Give up and make all public
  all_public
end

# Want some more complex role handling?
class ProfilesController < ApplicationController
  allow(:admin).to_access(:index)
  allow(:owner).to_access(:edit)
  publicize(:show)

  def index
    current_roles # => [#<SomeCustomRoleObject to_role_string: "admin", filters: [...]>]
  end

  def edit # Raises permission error before entering this
    current_roles # => []
  end

  def show
    current_roles # => []
  end

  def current_user_roles
    current_user.roles # => [#<SomeCustomRoleObject to_role_string: "admin", filters: [...]>, #<SomeCustomRoleObject to_role_string: "scorekeeper", filters: [...]>]
  end
  private :current_user_roles
end
```

# Allow roles with a resource
`allow_with_resource` acts similarly to `allow` but executes a resource check on the `SomeCustomerRoleObject` to access the endpoint.

This requires a method to be defined on `SomeCustomRoleObject` that checks if the resource is valid for that role.

The `rolypoly_resource_map` needs to be defined on the controller to pass the resources that the role will be validated against.
If `rolypoly_resource_map` is not defined it will be defaulted to an empty hash `{}`.


```ruby
class SomeCustomRoleObject
  def resource?(resource)
    self.resources.includes?(resource)
  end
end

class ProfilesController < ApplicationController
  allow(:admin).on(:organization).to_access(:index)
  allow(:owner).on(:profile).to_access(:edit)
  publicize(:show)

  def index
    current_roles # => [#<SomeCustomRoleObject to_role_string: "admin", resource?: true >]
  end

  def edit # Raises permission error before entering this
    current_roles # => []
  end

  def show
    current_roles # => []
  end

  private def current_user_roles
    current_user.roles # => [#<SomeCustomRoleObject to_role_string: "admin", resource?: true>, #<SomeCustomRoleObject to_role_string: "scorekeeper", resource?: false>]
  end

  private def rolypoly_resource_map
    {
      organization: ['Organization', tournament.org_id]
      tournament: tournament
    }
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
