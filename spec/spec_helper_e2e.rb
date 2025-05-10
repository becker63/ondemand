# frozen_string_literal: true

require 'beaker-rspec'
require 'e2e/e2e_helper'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  c.before(:suite) do
    cached = load_container_state

    if cached
      puts "Restored from cached container with OnDemand installed..."
      # Need to reinstall Apache since it's a fresh container
      if apt?
        install_packages(['apache2'])
      else
        install_packages(['httpd'])
      end
      # Then continue with configuration
      fix_apache
      on hosts, 'ls -l /etc/ood && ls -l /etc/ood/config || echo "no config dir"'
      upload_portal_config('portal.yml')
      update_ood_portal
      restart_apache
      restart_dex
    else
      puts "No cached container found, running full setup..."
      bootstrap_repos
      ondemand_repo
      install_ondemand
      on hosts, 'ls -l /etc/ood && ls -l /etc/ood/config || echo "no config dir"'
      # Save container state right after install_ondemand
      save_container_state
      # Continue with configuration
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
    dl_ctr_logs
  end
end
