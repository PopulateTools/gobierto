module GobiertoAdmin
  class UsersController < BaseController
    def index
      @users = get_users_in_current_site.sorted
    end

    def show
      @user = find_user
    end

    def edit
      @user = find_user
      @user_form = UserForm.new(
        @user.attributes.except(*ignored_user_attributes)
      )
    end

    def update
      @user = find_user
      @user_form = UserForm.new(user_params.merge(id: params[:id]))

      if @user_form.save
        redirect_to edit_admin_user_path(@user), notice: t(".success")
      else
        render :edit
      end
    end

    private

    def get_users_in_current_site
      User.by_source_site(current_site)
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
      source_site_id
      census_verified
      )
    end
  end
end
