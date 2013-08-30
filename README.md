# Rolypoly

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

## Usage

```ruby
class ApplicationController < ActionController::Base
  def current_roles
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
  publicize :landing

  def landing
    # ...
  end

  # Give up and make all public
  all_public
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
