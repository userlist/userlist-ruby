# Userlist for Ruby Changelog

## Unreleased (main)

- Updates ActiveJob Worker to retry on errors with polynomially longer wait times, up to 10 attempts
- Improve internal error handling to rely on exceptions

## v0.9.0 (2024-03-19)

- Allows deleteing resources by using other identifiers (like email)
- Relaxes requirement for providing associations. Incomplete resources will not be pushed anyways.
- Improves checks for whether a resource is pushable or not
- Fixes a typo in the occurred_at attribute of events while maintaining backwards compatibility

## v0.8.1 (2023-11-30)

- Fixes issue with customizability of push? and delete? methods on events and relationships

## v0.8.0 (2023-08-02)

- Adds a ActiveJob push strategy
- Adds support for retries of failed requests
- Adds response logging to the push client
- Adds support for payloads on delete requests

## v0.7.2 (2022-10-20)

- Improves connection handling between requests
- Improves handling of arguments passed to Sidekiq

## v0.7.1 (2022-02-10)

- Fixes issue with Sidekiq payloads (#4)

## v0.7.0 (2022-02-02)

- Allows users without an identifier but with an email address

## v0.6.0 (2021-05-14)

- Automatically manage one side of the relationships
- Always requires a user and a company on relationships

## v0.5.0 (2021-01-22)

- Adds support for relationships
- Adds support for company events
- Adds support for skipping certain operations
- Adds lazy lookup for push strategies
- Adds a Sidekiq push strategy
- Allow numerics as identifiers
- Improves Userlist::Token to work with more than just strings
- Improves the way resources are serialized
- Improves JSON serialization
- Replaces userlist.io with userlist.com
- Require at least Ruby 2.4

## v0.4.1 (2020-03-16)

- Fixes a problem when configuring the client (#1)

## v0.4.0 (2020-03-06)

- Adds improved error messages for configuration errors
- Adds support for user token generation
- Require at least Ruby 2.3

## v0.3.0 (2019-06-27)

- Adds additional aliases for the create method
- Adds resource models for User, Company, and Event
- Adds a more flexible interface to the push client
- Adds more HTTP methods to the push client

## v0.2.2 (2019-03-18)

- Adds support for Ruby 2.2

## v0.2.1 (2019-03-13)

- Adds support for Ruby 2.3

## v0.2.0 (2018-11-21)

- Adds the ability to adjust the configuration
- Adds convenience class methods to Userlist::Push
- Adds track and identify aliases for event and user push methods
- Adds null strategy that discards everything for testing purposes
- Adds logging support
- Adds threaded push strategy to deliver requests without blocking the main thread
- Adds Userlist::Push as a nicer interface to the push endpoint
- Require at least Ruby 2.1

## v0.1.0 (2018-01-18)

- Initial release
