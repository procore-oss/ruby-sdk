# Procore Gem

[![CircleCI](https://circleci.com/gh/procore/ruby-sdk/tree/master.svg?style=svg)](https://app.circleci.com/pipelines/github/procore/ruby-sdk?branch=master)

#### Table of Contents
- [Installation](#installation)
- [Configuration](#configuration)
- [Making Requests](#making-requests)
- [Usage](#usage)
- [Error Handling](#error-handling)
- [Pagination](#pagination)
  - [Navigating Through Paginated Results](#navigating-through-paginated-results)
  - [Change Number of Results](#change-number-of-results)
- [Sync Actions](#sync-actions)
- [Stores](#stores)
  - [Session Store](#session-store)
  - [Redis Store](#redis-store)
  - [Dalli Store](#dalli-store)
  - [ActiveRecord Store](#activerecord-store)
  - [File Store](#file-store)
  - [Memory Store](#memory-store)
- [Full Example](#full-example)
- [Contributing](#contributing)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "procore"
```

## Configuration

The Procore Gem exposes a configuration with several options.

For example, when using this gem in a Rails application, the configuration can be done like below:
```ruby
# config/initializes/procore.rb

require "procore"
Procore.configure do |config|
  # Base API host name. Alter this depending on your environment - in a
  # staging or test environment you may want to point this at a sandbox
  # instead of production.
  config.host = ENV.fetch("PROCORE_BASE_API_PATH", "https://api.procore.com")

  # Base Login host name used by the OAuth client to generate API tokens.
  # Alter this depending on your environment - in a staging or test environment
  # you may want to point this at a sandbox instead of production.
  config.login_host = ENV.fetch("PROCORE_BASE_LOGIN_PATH", "https://login.procore.com")

  # When using #sync action, sets the default batch size to use for chunking
  # up a request body. Example: if the size is set to 500, and 2,000 updates
  # are desired, 4 requests will be made. Note, the maximum size is 1000.
  config.default_batch_size = 500

  # The default API version to use if none is specified in the request.
  # Should be either "v1.0" (recommended) or "vapid" (legacy).
  config.default_version = "v1.0"

  # Integer: Number of times to retry a failed API call. Reasons an API call
  # could potentially fail:
  # 1. Service is briefly down or unreachable
  # 2. Timeout hit - service is experiencing immense load or mid restart
  # 3. Because computers
  #
  # Defaults to 1 retry. Would recommend 3-5 for production use.
  # Has exponential backoff - first request waits a 1.5s after a failure,
  # next one 2.25s, next one 3.375s, 5.0, etc.
  config.max_retries = 3

  # Float: Threshold for canceling an API request. If a request takes longer
  # than this value it will automatically cancel.
  config.timeout = 5.0

  # Instance of a Logger. This gem will log information about requests,
  # responses and other things it might be doing. In a Rails application it
  # should be set to Rails.logger
  config.logger = Rails.logger

  # String: User Agent sent with each API request. API requests must have a user
  # agent set. It is recomended to set the user agent to the name of your
  # application.
  config.user_agent = "MyAppName"
end
```

## Making Requests

At the core of the gem is the `Client` class. Clients are initialized with a
`client_id` and `client_secret` which can be obtained by signing up for
Procore's [Developer Program](https://developers.procore.com/).

A client requires a store. A store manages a particular user's access token.
Stores automatically manage tokens for you - refreshing, revoking and storage
are abstracted away to make your code as simple as possible. There are several
different [types of stores](#stores) available to you.

The `Client` class exposes `#get`, `#post`, `#put`, `#patch`, `#sync` and
`#delete` methods to you.

```ruby
   get(path, version: "", query: {}, options: {})
  post(path, version: "", body: {}, options: {})
   put(path, version: "", body: {}, options: {})
 patch(path, version: "", body: {}, options: {})
delete(path, version: "", query: {}, options: {})
  sync(path, version: "", body: {}, options: {})
```

#### The `path` and `version`

All paths are relative, the gem will handle expanding them. An API version can be specified in the `version:` argument, otherwise the `default_version` in the configuration will be used. 

| Example | Requested URL |
| --- | --- |
| `client.get("me")` | `https://api.procore.com/rest/v1.0/me` |
| `client.get("me", version: "v1.1")` | `https://api.procore.com/rest/v1.1/me` |
| `client.get("me", version: "vapid")` | `https://api.procore.com/vapid/me` |

#### Requiring `company_id` in the `options`

In order for your application to work with [Multiple Procore Zones (MPZ)](https://developers.procore.com/documentation/tutorial-mpz), each call your application makes to the Procore API **must** contain a request header that includes the `Procore-Company-Id` field. This request header field specifies the id of the company into which you are making the call.

This can be achieved by setting the `company_id` in the request `options`. (And this gem will convert it into a `Procore-Company-Id` header automatically.)

For example:
```ruby
client.get("companies/12345/users", options: { company_id: 12345 })
```

Note: Only the following Procore API endpoints do not require a request header containing the `Procore-Company-Id` field:
* Show User Info - (GET /rest/v1.0/me)
* List Companies - (GET /rest/v1.0/companies)

#### Example Usage

```ruby
store = Procore::Auth::Stores::Session.new(session: session)
client = Procore::Client.new(
  client_id: "client id",
  client_secret: "client secret",
  store: store
)

# Get the current user's companies
companies = client.get("companies").body

companies.first[:name] #=> "Procore Company 1"

# Get a company's projects (note the company_id value in options)
projects = client.get("projects", query: {company_id: <company_id>}, options: {company_id: <company_id>}).body

projects.first[:name] #=> "Project 1"
```

## Usage

The first step is to place the user's token into the store. For this example,
the tokens will be stored in the Rails session. In the controller action that
handles the end of the [OAuth 2.0
Flow](https://developers.procore.com/documentation/oauth-introduction) add the
following code:

```ruby
def handle_callback
  if auth_hash.blank?
    redirect_to '/auth/procore'
  else
    auth_hash = request.env['omniauth.auth']

    # Create a new token to save into a store
    token = Procore::Auth::Token.new(
      access_token: auth_hash["credentials"]["token"],
      refresh_token: auth_hash["credentials"]["refresh_token"],
      expires_at: auth_hash["credentials"]["expires_at"]
    )

    store = Procore::Auth::Stores::Session.new(session: session)
    store.save(token)

    redirect_to root_path
  end
end
```

With the user's token stored, requests can be made from anywhere in the
application that has access to the Rails session.

```ruby
client = Procore::Client.new(
  client_id: Rails.application.secrets.procore_app_id,
  client_secret: Rails.application.secrets.procore_app_secret,
  store: Procore::Auth::Stores::Session.new(session: session)
)

client.get("me")
```

Expired tokens will automatically be refreshed, but can also be refreshed manually:

```ruby
client.refresh
```

Tokens may also be manually revoked, forcing the client to refresh its token on the next request:

```ruby
client.revoke
```

## Error Handling

The Procore Gem raises errors whenever a request returns a non `2xx` response.
Errors return both a message detailing the error and an instance of a
`Response`.

```ruby
begin
  # Use Procore Gem to make requests
  client.get("projects")

rescue Procore::RateLimitError => e
  # Raised when a token reaches its request limit for the current time period.
  # If you are receiving this error then you are making too many requests
  # against the Procore API.

rescue Procore::NotFoundError => e
  # Raised when the request 404's

rescue Procore::InvalidRequestError => e
  # Raised when the request is incorrectly formatted. Possible causes: missing
  # required parameters or sending a request to access a non-existent resource.

rescue Procore::MissingTokenError => e
  # Raised whenever an access token is nil or invalid.

rescue Procore::AuthorizationError => e
  # Raised when the request is attempting to access a resource the token's
  # owner does not have access to.

rescue Procore::ForbiddenError => e
  # Raised when the request failed because you lack the required permissions.

rescue Procore::APIConnectionError => e
  # Raised when the gem cannot connect to the Procore API. Possible causes:
  # Procore is down or the network is doing something funny.

rescue Procore::ServerError => e
  # Raised when a Procore endpoint returns a 5xx response code.

rescue Procore::Error => e
  # Generic catch all error.

rescue => e
  # Something unrelated to Procore errored.
end
```

Note that all errors inherit from `Procore::Error`, so if you do not need to
handle each error uniquely you can just rescue from this base class to catch all
errors generated by this gem.

```ruby
begin
  client.get("projects")
rescue Procore:Error => e
  # Something went wrong.

  # Print the error class
  puts e.class

  # Print the error message
  puts e.message

  # Print the HTTP code
  puts e.response.code

  # Print the json error response
  puts e.response.errors

  # Print the headers
  puts e.response.headers
end
```

When client is calling `#refresh` or `#revoke` to refresh or revoke an access token, `Procore::OAuthError` will be raised if an exception happens.

```ruby
begin
  # Use Procore Gem to make refresh or revoke access token
  client.refresh

rescue Procore::OAuthError => e
  # Raised whenever there is a problem with OAuth. Possible causes: required
  # credentials are missing or an access token failed to refresh.
end
```

## Pagination
Endpoints which return multiple objects (a collection) will include pagination
information. The `Response` object has a `#pagination` method that will return
a hash which may conditionally contain the following keys:

```
:next  URL for the immediate next page of results.
:last  URL for the last page of results.
:first URL for the first page of results.
:prev  URL for the immediate previous page of results.
```

For example, on the first page of results the `#pagination` method will look
like:

```ruby
response.pagination

{
  next: "projects?per_page=100&page=2",
  last: "projects?per_page=100&page=5"
}
```

The `next` value will return the second page of results - which is expected as
all paginated responses start on page 1. The `last` value ends on page 5, so
there are another 4 pages to consume in order to get all the possible results.

### Navigating Through Paginated Results

To get the next page of results, just pass the url into `client#get`. You may
want to guard against the next page being potentially empty.

```ruby
first_page = client.get("projects")

if first_page.pagination[:next]
  next_page = client.get(first_page.pagination[:next])
end

puts next_page.pagination

{
  first: "projects?per_page=100&page=1",
  next: "projects?per_page=100&page=3",
  prev: "projects?per_page=100&page=1",
  last: "projects?per_page=100&page=5"
}
```

### Change Number of Results

You can pass a `per_page` query parameter in your request to change the page
size. The pagination links will update to reflect that change.

```
first_page = client.get("projects", query: { per_page: 250 })

puts first_page.pagination
{
  next: "projects?per_page=250&page=2",
  last: "projects?per_page=250&page=2"
}
```

Notice that because `per_page` has been set to 250, there are only two pages of
results (500 resources / 250 page size = 2 pages).

## Sync Actions
The Sync action enables batch creation or updates to resources using a single
call. When using a Sync action, the resources to be created or updated can be
specified by supplying either an `id` or an `origin_id` in the request body.
Utilizing the `origin_id` attribute for batch operations is often preferable as
it allows you to easily link to external systems by maintaining your own list of
unique resource identifiers outside of Procore.

The caller provides an array of hashes, each hash containing the attributes for
a single resource. The attribute names in each hash match those used by the
Create and Update actions for the resource. Attributes for a maximum of 1000
resources within a collection may be passed with each call. The API will always
return an HTTP status of 200.

The response body contains two attributes - `entities` and `errors`. The
attributes for each successfully created or updated resource will appear in the
entities list. The attributes for each resource will match those returned by the
Show action. For each resource which could not be created or updated, the
attributes supplied by the caller are present in the errors list, along with an
additional errors attribute which provides reasons for the failure.

[Continue reading
here.](https://developers.procore.com/documentation/using-sync-actions)

Example Usage:

```ruby
client.sync(
 "projects/sync",
 body: {
   updates: [
    { id: 1, name: "Update 1" },
    { id: 2, name: "Update 2" },
    { id: 3, name: "Update 3" },
    ...
    ...
    { id: 5055, name: "Update 5055" },
   ]
 },
 options: { batch_size: 500, company_id: 1 },
)
```

## Stores

Stores contain logic for accessing, storing, and managing access tokens. The
Procore API uses expiring tokens - this gem abstracts away the need to manually
refresh tokens.

Available stores:

### Session Store

Options: `session`: Instance of a Rails session

For applications that want to keep access tokens in the user's session.

:warning:
We strongly discourage using the session as a token store since the rails
session is often logged by default to external apps such as bugsnag etc. Be sure
you are not logging tokens. There is also the possibility that the rails session
is using a cookie store which, depending on application settings, could be
unencrypted. Tokens should not be stored client-side if it can be avoided.
:warning:

```ruby
store = Procore::Auth::Stores::Session.new(session: session)
```

### Redis Store

Options: `redis`: Instance of Redis
Options: `key`: Unique identifier to an access token

For applications which want to store access tokens in Redis. There's two
required options, `redis` which is an instance of a Redis connection, and `key`
which is a unique key which will be used to save / retrieve an access token.
The key will usually be the id of the current user.

```ruby
store = Procore::Auth::Stores::Redis.new(redis: Redis.new, key: current_user.id)
```

### Dalli Store

Options: `dalli`: Instance of Dalli
Options: `key`: Unique identifier to an access token

For applications which want to store access tokens in memcached using Dalli.
There's two required options, `dalli` which is an instance of a Dalli client,
and `key` which is a unique key which will be used to save / retrieve an access
token.  The key will usually be the id of the current user.

```ruby
store = Procore::Auth::Stores::Dalli.new(dalli: Dalli.new, key: current_user.id)
```

### ActiveRecord Store

Options: `object`: Instance of an ActiveRecord model.

For applications that store access token information on some user object.

The following columns **must** exist on the model you pass in:
`access_token`, `refresh_token` and `expires_at`.

```ruby
store = Procore::Auth::Stores::ActiveRecord.new(object: current_user)
```

### File Store

Options: `path`: Path to a file to store access tokens
Options: `key`: Unique identifier to an access token

Intended for command line applications, the File Store saves access token
information to disk. This way a user can run a CLI without needing to
authenticate every single command.

```ruby
store = Procore::Auth::Stores::File.new(path: "./tokens.yml", key: current_user.id)
```

### Memory Store

Options: `key`: Unique identifier to an access token

The most basic store - a token is kept in memory for the duration of a request.
This store type is not recommended for application usage - it is meant to be
used in tests.

```ruby
store = Procore::Auth::Stores::Memory.new(key: current_user.id)
```

## Full Example

```ruby
# In controller, callback from oauth
def handle_callback
  if auth_hash.blank?
    redirect_to '/auth/procore'
  else
    auth_hash = request.env['omniauth.auth']

    # Create a new token to save into a store
    token = Procore::Auth::Token.new(
      access_token: auth_hash["token"]
      refresh_token: auth_hash["refresh_token"],
      expires_at: auth_hash["expires_at"]
    )

    store = Procore::Auth::Stores::Session.new(session: session)
    store.save(token)

    redirect_to root_path
  end
end

# Somewhere else in the application
class ProjectsController
  def index
    @projects = client.get("projects", query: { company_id: params[:company_id] })
  end

  private

  def client
    @client ||= Procore::Client.new(
      client_id: Rails.application.secrets.procore_client_id,
      client_secret: Rails.application.secrets.procore_client_secret,
      store: Procore::Auth::Stores::Session.new(session: session)
    )
  end
end
```

## Contributing

To contribute to the gem, please clone the repo and cut a new branch. In the PR, update the changelog with a short explanation of what you've changed, and your name under the "Unreleased" section. Example changelog update:

```markdown
## Unreleased

* Short sentence of what has changed

    *Your Name*
```

Please **do not** bump the gem version in your PR. This will be done in a follow up by the gem maintainers.

## Releasing

Gem maintainer should follow these steps to release a new version:

1. Merge all PRs into the `master` branch that you want included in the release.
2. Update `version.rb` to a new semantic version, and move unreleased items in `CHANGELOG.md` into a section for that version.
3. Stage and commit changes. `git commit -a`
4. Create a tag for the new version. `git tag -a {version}`
5. Push the tagged commit `git push --follow-tags` and a new version will be published to RubyGems.

### Tests

To run the specs run the following command:
```bash
$ bundle exec rake test
```


## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

## About Procore

The Procore Gem is maintained by Procore Technologies.

Procore - building the software that builds the world.

Learn more about the #1 most widely used construction management software at
[procore.com](https://www.procore.com/)
