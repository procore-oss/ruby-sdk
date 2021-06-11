## 1.1.3 (Jun 11, 2021)

* Add Procore-Sdk-Language header to all requests

  PR #45 - https://github.com/procore/ruby-sdk/pull/45

  *Benjamin Ross*

* Remove Redis.exists warning

  PR #46 - https://github.com/procore/ruby-sdk/pull/46

  *claudioprocore*

## 1.1.2 (Jun 4, 2021)

* Add Procore-Sdk-Version header to all requests

  PR #44 - https://github.com/procore/ruby-sdk/pull/44

  *Benjamin Ross*

## 1.1.1 (May 5, 2021)

* Change default host to 'api.procore.com'.

  PR #42 - https://github.com/procore/ruby-sdk/pull/42

  *Nate Baer*

## 1.1.0 (March 11, 2021)

* Allow tokens to be revoked and manually refreshed.

  PR #39 - https://github.com/procore/ruby-sdk/pull/39

  *Nate Baer*

## 1.0.0 (January 5, 2021)

* Adds support for API versioning

  *Nate Baer*

### Upgrading

As of v1.0.0, this gem now defaults to making requests against Procore's new
Rest v1.0 resources, instead of the now deprecated `/vapid` namespace. Example:

```ruby
# Previously makes a request to
client.get("me")
=> app.procore.com/vapid/me

# In 1.0.0
client.get("me")
=> app.procore.com/rest/v1.0/me
```

To keep the legacy behavior, set the new `default_version` configuration option.
Note, that Rest v1.0 is a superset of the Vapid Api - there are no breaking
changes. The Vapid API will be decommissioned in December 2021.

[Read more here](https://developers.procore.com/documentation/vapid-deprecation)

```ruby
Procore.configure do |config|
  ...
  # Defaults to "v1.0"
  config.default_version = "vapid"
  ...
end
```

All the request methods (`get`, `post`, `patch`, `put`, `delete`, `sync`) now
accept an optional version parameter to specify the version at request time.

```ruby
client.get("me")
=> https://app.procore.com/rest/v1.0/me

client.get("me", version: "v1.1")
=> https://app.procore.com/rest/v1.1/me

client.get("me", version: "vapid")
=> https://app.procore.com/vapid/me
```

## 0.8.8 (October 17, 2019)

* Expose #sync, a method that enables calling sync-actions

  *Patrick Koperwas*

* Addition of contribution guidelines to README

  *Megan O'Neill*

* Fix TravisCI failures

  *Patrick Koperwas*

## 0.8.7 (April 18, 2019)

* Add api_version to allow calls to procore rest endpoints

  *Shane Means*

## 0.8.6 (May 10, 2018)

* Dalli Store

  *Patrick Koperwas*

* Fix Requestable paths to prevent double slash in URI

    *Megan O'Neill*

## 0.8.5 (May 9, 2018)
* Rescue Errno::ECONNREFUSED errors and RestClient::ServerBrokeConnection

    *Casey Ochs*

## 0.8.4 (May 8, 2018)

* Use symbol key access for headers object

  PR #23 - https://github.com/procore/ruby-sdk/pull/23

    *Michael Stock*

## 0.8.3 (May 7, 2018)

## 0.8.2 (May 7, 2018)

* Rescue Procore::OAuthError
* Add Procore::MissingTokenError

    *Casey Ochs*

## 0.8.1 (April 13, 2018)

* Fix rubocop

    *Michael Stock/Jason Gittler*

## 0.8.0 (April 13, 2018)

* Move all request methods to use keyword arguments

    *Michael Stock/Jason Gittler*

## 0.7.3 (March 1, 2018)

* Add 403 responses as Procore::ForbiddenError

    *Michael Stock*

## 0.7.2 (February 28, 2018)

*  Add 400 responses as Procore::InvalidRequestError

   *Michael Stock*

*  Add request_body to Procore::Response for debugging

   *Michael Stock*

## 0.7.1 (February 22, 2018)

*  Fix redis store guard clause

   *Patrick Koperwas*

## 0.7.0 (February 21, 2018)

* Add multipart request support
* Move to `RestClient` from `HTTParty`

  *Matt Brinza*

## 0.6.9 (February 09, 2018)

*  Add HTTP PUT support

   *Matt Brinza*

## 0.6.8 (January 04, 2018)

* Wrap `AccessTokenCredentials` external errors with our own errors

## 0.6.7 (January 04, 2018)

* Allow gem to be pushed to RubyGems

## 0.6.6 (January 04, 2018)

* Move to using TravisCI
* Publish to RubyGems

## 0.6.5 (January 04, 2018)

* Add response to `OAuthError`

## 0.6.4 (December 15, 2017)

* Fix issue with passing request into `Procore::Response`.

  *Michael Stock*

## 0.6.3 (December 11, 2017)

*  Fix issue with client credentials by forcing the usage of request body
   for sending `client_id` and `client_secret`

   *Michael Stock*

## 0.6.2 (December 6, 2017)

*  Fix session store not saving off the optional key attribute

   PR #2 - https://github.com/procore/ruby-sdk/pull/2

   *Patrick Koperwas*

## 0.6.1 (December 6, 2017)

*  Change error class for 404s.

   Previously a 404 would raise a Procore::InvalidRequestError. Now, a 404 will
   raise a Procore::NotFoundError,

   PR #1 - https://github.com/procore/ruby-sdk/pull/1

   *Patrick Koperwas*
