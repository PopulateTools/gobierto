## Null strategy for authentication

The behaviour ot this strategy is to not return a user at all for authentication.

This strategy provides some models and views:

- In `app/forms/user`: `NullStrategySessionForm` - FormObject inherited from `UserSessionForm`. It's responsible for validating session and returning a valid user from data received from controller. The controller takes all params and stores them in a data field. Also some other fields, like `site`, `creation_ip`, `referrer_url`, `referrer_entity` and `callback_url` are included in the base FormObject attributes. The FormObject must implement a save method which is expected to return a boolean. The FormObject also must set a value for the user attribute. The FormObject can define a `redirect_new_url` for redirections to external authentication systems. Also the FormObject can define an `authentication_data_invalid?` which makes the controller to exit from authentication process and return to root path. This can be used when the data received for an external auth provider is invalid or corrupted.
- In `lib/validations/`: There you can define the extra validations required for the FormObject
- In `views/user/custom_sessions/null_strategy/` There must be at least two partials:
  - `_new_form.html.erb` This partial will be inserted in the sign-in form and it should request the data required to validate user session.
  - `_edit_form.html.erb`If after submit the data, the information is not enough to create the session, this form is shown. Typically, if an external authentication provider returns valid information of the user but some required fields, like email, are missing, with this form requiring email, the data can be completed to create a new user.
- In `config/locales/views`: There you can set the values for i18n keys used in partials
