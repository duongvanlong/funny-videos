require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Funnyvideos
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.to_prepare do
    Devise::SessionsController.layout "authentication"
    Devise::RegistrationsController.layout "authentication"
    Devise::ConfirmationsController.layout "authentication"
    Devise::PasswordsController.layout "authentication"
end
  end
end
