## Unreleased

## 0.6.1 (December 6, 2017)

*  Change error class for 404s.

   Previously a 404 would raise a Procore::InvalidRequestError. Now, a 404 will
   raise a Procore::NotFoundError,

   PR #1 - https://github.com/procore/ruby-sdk/pull/1

   *Patrick Koperwas*
