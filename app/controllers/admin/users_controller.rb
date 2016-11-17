class Admin::UsersController < Admin::BaseController
  def index
    @users = User.sorted.all
  end

  def show
    @user = find_user
  end

  def edit
    @user = find_user
    @user_form = Admin::UserForm.new(
      @user.attributes.except(*ignored_user_attributes)
    )
  end

  def update
    @user_form = Admin::UserForm.new(user_params.merge(id: params[:id]))

    if @user_form.save
      redirect_to admin_users_path, notice: "User was successfully updated."
    else
      render :edit
    end
  end

  private

  def find_user
    User.find(params[:id])
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
    )
  end
end
