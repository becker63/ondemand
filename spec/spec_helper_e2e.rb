# frozen_string_literal: true

require 'beaker-rspec'
require 'e2e/e2e_helper'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  c.before(:suite) do
    # Try to load cached container first
    cached = load_container_state

    if cached
      puts "Restored from cached container, running minimal setup..."
      # Install Apache first since it's not in the container
      if apt?
        install_packages(['apache2'])
      else
        install_packages(['httpd'])
      end
      # Then continue with service setup
      fix_apache
      upload_portal_config('portal.yml')
      update_ood_portal
      restart_apache
      restart_dex
    else
      puts "No cached container found, running full setup..."
      bootstrap_repos
      ondemand_repo
      install_ondemand
      fix_apache
      upload_portal_config('portal.yml')
      update_ood_portal
      restart_apache
      restart_dex
      bootstrap_user
      bootstrap_flask
    end
  end

  c.after(:suite) do
    save_container_state
    dl_ctr_logs
  end
end
