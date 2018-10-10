# frozen_string_literal: true

class AddFuzzystrmatchModule < ActiveRecord::Migration[5.2]
  def change
    enable_extension("fuzzystrmatch")
  end
end
