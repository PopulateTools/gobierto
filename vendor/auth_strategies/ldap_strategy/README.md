## LDAP strategy for authentication

This strategy is used to authenticate users using a set of configurable LDAP providers.

The LDAP providers can be configured in other configuration variables of site under ldap
key. The configuration has a `ldap_username`, a `ldap_password` and a variable list of
configurations including:
* The `host`, `port` and `domain` of a LDAP service
* `authentication_query`. This string be used to authenticate the user in the LDAP service.
The data introduced as user identifier (usually an email) will be interpolated in the
query replacing the `%{user_identifier}` part.
* `password_field`: The attribute used to store the password in LDAP
* `email_field` and `name_field`. The attributes of LDAP used to create a new user in case
it does not exist in Gobierto.

This is an example of LDAP configuration in other configuration variables of site:

```yaml
ldap:
  ldap_username: uid=aa729,ou=people,dc=example,dc=org
  ldap_password: smada
  configurations:
    -
      host: 127.0.0.1
      port: 3897
      domain: dc=example,dc=org
      authentication_query: mail=%{user_identifier},dc=example,dc=org
      password_field: userPassword
      email_field: mail
      name_field: cn
```

If a user enters authentication data the strategy goes through the services until a service
can validate the user. Then the strategy gets the email and user name from the service and
uses them to find or create the Gobierto user. This strategy mantains the default gobierto
authentication strategy, with email and password, so if a user is not found in LDAP have
access with a valid email and password combination. To prevent this the password mechanism
can be disabled on the strategy configuration (see below)

### Install

To make available from site configuration admin part, add to `auth_modules` in
`config/application.yml`:

```ruby
    -
      name: ldap_strategy
      description: LDAP strategy
      session_form: LdapSessionForm
      password_enabled: true
      domains: ['site1.gobierto.test', 'site2.gobierto.test']
      default: false
```

The `password_enabled` option as false disables the password feature from settings pages.

The `domains` variable contains the list of sites for which the strategy will be available.
The site must have the domain included in the list. If this option is ignored or blank, the
strategy will be available for all sites.

**Warning**

`session_form` makes use of a class defined in `forms/user`, `LdapStrategy`. In environments
other than development, to ensure that all required classes are available, the files must be
required on eager load. Add them in `lib/ldap_strategy.rb`. Otherwise the appication will fail
on production and staging:

```ruby
# frozen_string_literal: true

require 'active_support'

class LdapStrategy
  extend ActiveSupport::Autoload

  def self.eager_load!
    super
    require_relative '../app/forms/user/ldap_session_form'
  end
end
```
