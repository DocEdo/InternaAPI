# frozen_string_literal: true

require 'sequel'

Sequel.migrtion do
  change do
    create_table(:jobs) do
      primary_key :id
      foreign_key :company_id, table: :companies

      String :jobname, null: false
      String :relative_path, null: false, default: ''
      String :description
      String :content, null: false, default: ''

      DateTime :create_at
      DateTime :updated_at

      unique [:company_id, :relative_path, :jobname]
    end
  end
end