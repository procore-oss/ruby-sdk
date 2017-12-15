## Unreleased

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
