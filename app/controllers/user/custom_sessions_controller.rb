# frozen_string_literal: true

class User::CustomSessionsController < User::BaseController
  before_action :authenticate_user!, only: [:destroy]
  before_action :require_no_authentication, only: [:new, :create]
  skip_before_action :verify_authenticity_token, only: [:auth_callback]

  layout "user/layouts/sessions"

  def new
    redirect_to auth_path and return if !auth_modules_present?
    set_user_session_forms

    if params[:open_modal]
      @modal = true
      render(:new, layout: false) && return if request.xhr?
    else
      redirect_to_provider_if_required
    end
  end

  def auth_callback
    create(false)
  end

  def create(invalid_messages = true)
    set_user_session_forms

    if @user_session_forms.values.any?(&:save)
      @valid_session_form = @user_session_forms.values.find(&:valid?)
      sign_in

    elsif @user_session_forms.values.any?(&:authentication_data_invalid?)
      redirect_to(
        after_sign_out_path,
        alert: t('user.custom_sessions.create.invalid_data')
      ) and return

    else
      if invalid_messages && (errors_form = @user_session_forms.values.find { |session_form| session_form.errors.any? }).present?
        flash[:alert] = errors_form.errors.full_messages.to_sentence
      end

      @strategy_name, @user_session_form = @user_session_forms.find do |key, form|
        form.invalid?
      end

      if params[:open_modal]
        render(:edit, layout: false) && return if request.xhr?
      end

      render :edit
    end
  end

  def destroy
    sign_out_user
    redirect_to after_sign_out_path, notice: t('user.custom_sessions.destroy.success')
  end

  private

  def sign_in
    user = @valid_session_form.user
    if user.confirmed?
      user.update_session_data(remote_ip)
      sign_in_user(user.id)

      redirect_to(
        after_sign_in_path(@valid_session_form.referrer_url),
        notice: t('user.custom_sessions.create.success')
      ) and return
    else
      redirect_to(
        after_sign_out_path,
        notice: t('user.custom_sessions.create.not_confirmed')
      ) and return
    end
  end

  def set_user_session_forms
    @user_session_forms = current_site.configuration.auth_modules_data.inject({}) do |user_session_forms, auth_module|
      user_session_forms.merge(auth_module.name => User.const_get(auth_module.session_form).new(site: current_site,
                                                                                                creation_ip: remote_ip,
                                                                                                referrer_url: referrer_url,
                                                                                                referrer_entity: referrer_entity,
                                                                                                data: params.permit!))
    end
  end

  def redirect_to_provider_if_required
    if @user_session_forms.keys.count == 1
      custom_session_form = @user_session_forms.values.first
      redirect_to custom_session_form.redirect_new_url if custom_session_form.redirect_new_url.present?
    end
  end

  def referrer_url
    @referrer_url ||= if params.has_key?(:user_session)
                        params.require(:user_session).permit(:referrer_url)[:referrer_url]
                      else
                        params[:referrer] || request.referrer
                      end
  end

  def referrer_entity
    # this is disabled after removal of the old module. Previously, it was used to obtain an additional
    # verification specific to some modules, taking the user.referrer_entity, which points to the module
    # that required these steps.
    #
    # if request.referrer.present?
    #   if request.referrer.include?("gobierto-module-name-path")
    #     "GobiertoModuleName::ControllerName"
    #   end
    # end
  end

  def require_no_authentication
    redirect_to(
      after_sign_in_path,
    ) if user_signed_in?
  end
end
