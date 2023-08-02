# Userlist for Ruby  [![Build Status](https://github.com/userlist/userlist-ruby/workflows/Tests/badge.svg)](https://github.com/userlist/userlist-ruby)

This gem helps with integrating [Userlist](https://userlist.com) into Ruby applications.

> To integrate Userlist into a Ruby on Rails application, please use [userlist-rails](https://github.com/userlist/userlist-rails)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'userlist'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install userlist

## Configuration

The only required configuration is the Push API key. You can get your Push API key via the [Push API settings](https://app.userlist.com/settings/push) in your Userlist account.

Configuration values can either be set via the `Userlist.configure` method or as environment variables. The environment variables take precedence over configuration values from the initializer.

Configuration via environment variables:

```shell
USERLIST_PUSH_KEY=VvB7pjDrv0V2hoaOCeZ5rIiUEPbEhSUN
USERLIST_PUSH_ID=6vPkJl44cm82y4aLBIzaOhuEHJd0Bm7b
```

Configuration via an initializer:

```ruby
Userlist.configure do |config|
  config.push_key = 'VvB7pjDrv0V2hoaOCeZ5rIiUEPbEhSUN'
  config.push_id = '6vPkJl44cm82y4aLBIzaOhuEHJd0Bm7b'
end
```

The possible configuration values are listed in the table below.

| Name                    | Default value                | Description                                                                                                                                |
| ----------------------- | ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `push_key`              | `nil`                        | The push key for your account. See [Push API settings](https://app.userlist.com/settings/push).                                            |
| `push_id`               | `nil`                        | The push id for your account. See [Push API settings](https://app.userlist.com/settings/push).                                             |
| `push_endpoint`         | `https://push.userlist.com/` | The HTTP endpoint that the library will send data to.                                                                                      |
| `push_strategy`         | `:threaded`                  | The strategy to use to send data to the HTTP endpoint. Possible values are `:threaded`, `:sidekiq`, `:active_job`, `:direct`, and `:null`. |
| `push_strategy_options` | `{}`                         | Any additional options for the push strategy.                                                                                              |
| `log_level`             | `:warn`                      | The log level for Userlist related log messages. Possible values are `:debug`, `:error`, `:fatal`, `:info`, and `:warn`                    |
| `token_lifetime`        | `3600`                       | The lifetime of generated in-app messages tokens in seconds                                                                                |

### Disabling in development and test environments

As sending test and development data into data into Userlist isn't very desirable, you can disable transmissions by setting the push strategy to `:null`.

```ruby
Userlist.configure do |config|
  config.push_strategy = :null
end
```

## Usage

This library is a wrapper for Userlist's Push API. For details about the accepted payloads, please check [its documentation](https://userlist.com/docs/getting-started/integration-guide/).

### Tracking Users

To manually send user data into Userlist, use the `Userlist::Push.users.push` method.

```ruby
Userlist::Push.users.push(
  identifier: 'user-1',
  email: 'foo@example.com',
  properties: {
    first_name: 'Foo',
    last_name: 'Example'
  }
)
```

It's also possible to delete a user from Userlist, using the `Userlist::Push.users.delete` method.

```ruby
Userlist::Push.users.delete('user-1')
```

### Tracking Companies

To manually send company data into Userlist, use the `Userlist::Push.companies.push` method.

```ruby
Userlist::Push.companies.push(
  identifier: 'company-1',
  email: 'Example, Inc.',
  properties: {
    industry: 'Software Testing'
  }
)
```

It's also possible to delete a user from Userlist, using the `Userlist::Push.companies.delete` method.

```ruby
Userlist::Push.companies.delete('user-1')
```

### Tracking Relationships

Tracking relationships can either be done using nested properties in user or company payloads or via the `Userlist::Push.relationships.push` method.

```ruby
Userlist::Push.relationships.push(
  user: 'user-1',
  company: 'company-1',
  properties: {
    role: 'owner'
  }
)
```

This is equivalent to specifying the relationship on the user model.

```ruby
Userlist::Push.users.push(
  identifier: 'user-1',
  relationships: [
    {
      company: 'company-1',
      properties: {
        role: 'owner'
      }
    }
  ]
)
```

It's also equivalent specifying the relationship on the company model.

```ruby
Userlist::Push.companies.push(
  identifier: 'company-1',
  relationships: [
    {
      user: 'user-1',
      properties: {
        role: 'owner'
      }
    }
  ]
)
```

### Tracking Events

To track custom events use the `Userlist::Push.events.push` method.

```ruby
Userlist::Push.events.push(
  name: 'project_created',
  user: 'user-1',
  properties: {
    project_name: 'Example project'
  }
)
```

Instead of just sending a user or company identifier, it's also possible to expand the properties into objects. This will update the user / company record as well as trigger the event in one operation.

```ruby
Userlist::Push.events.push(
  name: 'project_created',
  user: {
    identifier: 'user-1',
    properties: {
      projects: 5
    }
  },
  properties: {
    project_name: 'Example project'
  }
)
```

### Tokens for in-app messages

In order to use in-app messages, you must create a JWT token for the currently signed in user on the server side. To do this, please configure both the `push_key` and the `push_id` configuration variables. Afterwards, you can use the `Userlist::Token.generate` method to get a signed token for the given user identifier.

```ruby
Userlist::Token.generate('user-1')
# => "eyJraWQiOiI2dlBrSmw0NGNtODJ5NGFMQkl6YU9odU...kPGe8KX8JZBTQ"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/userlist/userlist-ruby>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Userlist project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/userlist/userlist-ruby/blob/master/CODE_OF_CONDUCT.md).

## What is Userlist?

[![Userlist](https://userlist.com/images/external/userlist-logo-github.svg)](https://userlist.com/)

[Userlist](https://userlist.com/) allows you to onboard and engage your SaaS users with targeted behavior-based campaigns using email or in-app messages.

Userlist was started in 2017 as an alternative to bulky enterprise messaging tools. We believe that running SaaS products should be more enjoyable. Learn more [about us](https://userlist.com/about-us/).
