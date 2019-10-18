# frozen_string_literal: true

module GobiertoCommon
  module Scrutinizer
    class Record < ApplicationRecord

      # ActiveRecord::Base.establish_connection(
      #   adapter:  "mysql2",
      #   host:     "localhost",
      #   username: "myuser",
      #   password: "mypass",
      #   database: "somedatabase"
      # )
      self.table_name = "imported_records"
    end
  end
end
