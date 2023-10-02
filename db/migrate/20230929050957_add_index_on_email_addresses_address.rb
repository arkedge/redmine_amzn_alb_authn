# frozen_string_literal: true

class AddIndexOnEmailAddressesAddress < ActiveRecord::Migration[6.1]
  def change
    add_index :email_addresses, :address, unique: true
  end
end
