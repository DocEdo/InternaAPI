# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    # Create a table called companies
    create_table(:companies) do
      # Create columns id as primary key and other colums like name and description
      primary_key :id

      # Unique true restrains other companies from having the same name
      String :name, unique: true, null: false
      String :description

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
