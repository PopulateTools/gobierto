module GobiertoAdmin
  class UsersController < BaseController

    include CustomFieldsHelper

    def index
      @users = get_users_in_current_site.sorted
      @users_stats = get_users_stats
    end

    def show
      @user = find_user
    end

    def edit
      @user = find_user
      @user_form = UserForm.new(
        @user.attributes.except(*ignored_user_attributes)
      )
      initialize_custom_field_form
    end

    def update
      @user = find_user
      @user_form = UserForm.new(user_params.merge(id: params[:id]))
      initialize_custom_field_form

      if @user_form.save && custom_fields_save
        track_update_activity
        redirect_to edit_admin_user_path(@user), notice: t(".success")
      else
        render :edit
      end
    end

    private

    def get_users_in_current_site
      User.by_site(current_site)
    end

    def find_user
      get_users_in_current_site.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :name,
        :bio,
        :email
      )
    end

    def ignored_user_attributes
      %w(
      created_at updated_at
      password_digest
      confirmation_token reset_password_token
      creation_ip last_sign_in_ip
      last_sign_in_at
      site_id
      census_verified
      date_of_birth
      gender
      notification_frequency
      referrer_entity
      referrer_url
      )
    end

    def track_update_activity
      Publishers::UserActivity.broadcast_event("user_updated", default_activity_params.merge({subject: @user_form.user, changes: @user_form.user.previous_changes.except(:updated_at)}))
    end

    def default_activity_params
      { ip: remote_ip, author: current_admin }
    end

    def get_users_stats
      GobiertoAdmin::Users::UsersStatsPresenter.new(current_site)
    end
  end
end
