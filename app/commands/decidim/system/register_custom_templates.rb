# frozen_string_literal: true

module Decidim
  module System
    # A command with all the business logic when creating a new organization in
    # the system. It creates the organization and invites the admin to the
    # system.
    class RegisterCustomTemplates < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        @organization = nil
        transaction do
          @organization = create_organization
          CreateDefaultPages.call(@organization)
          PopulateHelp.call(@organization)
          CreateDefaultContentBlocks.call(@organization)
        end
        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        broadcast(:invalid)
      end

      private

      attr_reader :form

      def create_organization
        Decidim::Organization.create!(
          name: form.name,
          host: form.host,
          reference_prefix: form.reference_prefix,
          organization_admin_name: form.organization_admin_name,
          organization_admin_email: form.organization_admin_email,
          available_locales: form.available_locales,
          default_locale: form.default_locale
        )
      end
    end
  end
end
