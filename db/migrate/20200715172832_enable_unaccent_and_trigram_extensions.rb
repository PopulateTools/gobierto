# frozen_string_literal: true

class EnableUnaccentAndTrigramExtensions < ActiveRecord::Migration[5.2]
  def change
    enable_extension("unaccent")
    enable_extension("pg_trgm")
  end
end
