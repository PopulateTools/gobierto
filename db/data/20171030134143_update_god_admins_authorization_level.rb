class UpdateGodAdminsAuthorizationLevel < ActiveRecord::Migration[5.1]

  def up
    GobiertoAdmin::Admin.where(god: true).each { |admin| admin.manager! }
  end

  def down
  end

end