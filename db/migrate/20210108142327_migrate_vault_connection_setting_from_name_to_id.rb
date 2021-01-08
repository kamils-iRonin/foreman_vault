# frozen_string_literal: true

class MigrateVaultConnectionSettingFromNameToId < ActiveRecord::Migration[5.1]
  def up
    setting = Setting::Vault.find_by(name: 'vault_connection')
    vault_connection_id = VaultConnection.unscoped.find_by(name: setting&.value)&.id
    setting&.update(value: vault_connection_id)
  end

  def down
    setting = Setting::Vault.find_by(name: 'vault_connection')
    vault_connection_name = VaultConnection.unscoped.find_by(id: setting&.value)&.name
    setting&.update(value: vault_connection_name)
  end
end
