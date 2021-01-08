# frozen_string_literal: true

class Setting
  class Vault < ::Setting
    BLANK_ATTRS << 'vault_connection'
    BLANK_ATTRS << 'vault_policy_template'

    def self.default_settings
      [set_vault_connection, set_vault_policy_template, set_vault_orchestration_enabled]
    end

    def self.load_defaults
      # Check the table exists
      return unless super

      transaction do
        default_settings.each { |s| create! s.update(category: 'Setting::Vault') }
      end

      true
    end

    def self.humanized_category
      N_('Vault')
    end

    class << self
      private

      def set_vault_connection
        set(
          'vault_connection',
          N_('Default Vault Connection that can be override using parameters'),
          default_vault_connection,
          N_('Default Vault Connection'),
          nil,
          collection: vault_connections_collection,
          include_blank: _('Select Vault Connection')
        )
      end

      def default_vault_connection
        return nil unless VaultConnection.table_exists?
        return unless VaultConnection.unscoped.count == 1

        VaultConnection.unscoped.first.id
      end

      def vault_connections_collection
        return [] unless VaultConnection.table_exists?

        proc { Hash[VaultConnection.unscoped.all.map { |vc| [vc.id, vc.name] }] }
      end

      def set_vault_policy_template
        set(
          'vault_policy_template',
          N_('The name of the ProvisioningTemplate that will be used for Vault Policy'),
          default_vault_policy_template,
          N_('Vault Policy template name'),
          nil,
          collection: vault_policy_templates_collection,
          include_blank: _('Select Template')
        )
      end

      def default_vault_policy_template
        ProvisioningTemplate.unscoped.of_kind(:VaultPolicy).find_by(name: 'Default Vault Policy')&.name
      end

      def vault_policy_templates_collection
        proc { Hash[ProvisioningTemplate.unscoped.of_kind(:VaultPolicy).map { |tmpl| [tmpl.name, tmpl.name] }] }
      end

      def set_vault_orchestration_enabled
        set(
          'vault_orchestration_enabled',
          N_('Enable or disable the Vault orchestration step for managing policies and auth methods'),
          false,
          N_('Vault Orchestration enabled')
        )
      end
    end
  end
end
