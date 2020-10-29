# v1.1.0

* removed dependency from non-Core modules (idea of using `inet_pton` to tell hostnames from addresses comes from the manpage
of `getent`);
* clarified similarities and differences between `resolve` and `getent hosts`;
* errors are now reported inline (previously a stack trace would be generated on STDERR through the `Carp` module);
* a tiny little bit of refactoring;
* added this changelog.

# v1.0.1

* improved the reporting for reverse resolution

# v1.0.0

* code refactoring;
* using `getaddrdinfo`, `getnameinfo` instead of `gethostby*`
* added README and LICENSE

# v0.1.0

Basically, just a draft.