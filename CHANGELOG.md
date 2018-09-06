## Unreleased

* Use login.procore.com for client credentials and access tokens

  *Megan O'Neill*

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
