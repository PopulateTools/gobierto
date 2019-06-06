# frozen_string_literal: true

class AddReferenceToInstanceInCustomFields < ActiveRecord::Migration[5.2]
  def change
    add_reference :custom_fields, :instance, polymorphic: true, index: true
  end
end
