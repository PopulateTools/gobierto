class AddSlugToGobiertoPeoplePersonPosts < ActiveRecord::Migration[5.0]

  def up
    add_column :gp_person_posts, :slug, :string
    create_slug_for_existing_posts
    change_column :gp_person_posts, :slug, :string, null: false
    add_index :gp_person_posts, :slug, unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def create_slug_for_existing_posts
    GobiertoPeople::PersonPost.all.each do |post|
      post.send(:set_slug)
      post.save!
    end
  end

end
