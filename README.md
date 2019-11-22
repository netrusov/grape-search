# Grape::Search

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'grape-search', github: 'netrusov/grape-search'
```

And then execute:
```
bundle install
```

## Usage

```ruby
module Searches
  class Users
    include Grape::Search

    self.default_scope = User.all

    search :id, type: Integer do |value|
      scope.where(id: value)
    end

    search :email, types: [String, Array[String]] do |value|
      scope.where(email: Array(value))
    end

    search :full_name, type: String do |value|
      first_name, last_name = value.split

      scope
        .joins(:profile)
        .where(
          profiles[:first_name].eq(first_name).and(profiles[:last_name].eq(last_name))
        )
    end

    search :created_at, type: Date do |value|
      scope.where(users[:created_at].gteq(value))
    end

    private

    def profiles
      Profile.arel_table
    end

    def users
      User.arel_table
    end
  end
end

class API < Grape::API
  namespace :users do
    params do
      optional :filters, type: Hash do
        search Searches::Users, except: :id do
          email required: true
          full_name values: ['John Doe', 'Jane Doe'], default: 'John Doe'
        end
      end
    end

    get do
      present :users, Searches::Users.new(permitted_params[:filters]).result, with: Grape::Presenters::Presenter
    end
  end

  helpers do
    def permitted_params
      @permitted_params ||= declared(params, include_missing: false)
    end
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/netrusov/grape-search.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
