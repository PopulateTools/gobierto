class AmendBlogSetting < ActiveRecord::Migration[5.1]
  def up
    GobiertoPeople::Setting.where(key: "blog_submodule_active").update_all(key: "blogs_submodule_active")
  end

  def down
    GobiertoPeople::Setting.where(key: "blogs_submodule_active").update_all(key: "blog_submodule_active")
  end
end
