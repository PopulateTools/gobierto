class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, defaut: ""
      t.string :name, null: false, defaut: ""
      t.string :bio
      t.string :password_digest, null: false, default: ""
      t.string :confirmation_token
      t.string :reset_password_token
      t.inet :creation_ip
      t.datetime :last_sign_in_at
      t.inet :last_sign_in_ip

      t.timestamps
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
  end
end
