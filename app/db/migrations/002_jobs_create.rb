# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:jobs) do
      primary_key :id
      foreign_key :company_id, table: :companies

      String :jobname, null: false
      String :description
      String :content, null: false, default: ''

      DateTime :create_at
      DateTime :updated_at

      unique [:company_id, :jobname]
    end
  end
end
