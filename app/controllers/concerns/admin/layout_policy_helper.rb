module Admin::LayoutPolicyHelper
  extend ActiveSupport::Concern

  private

  def can_manage_sites?
    @manage_sites ||= Admin::LayoutPolicy.new(current_admin, :manage_sites).can?
  end
end
