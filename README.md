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
class UsersController < ActionController::Base
  include Rolypoly::ControllerRoleDSL

  def index
    # ...
  end
  restrict(:index).to(:admin)
  # OR
  allow(:admin).access_to(:index)
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
