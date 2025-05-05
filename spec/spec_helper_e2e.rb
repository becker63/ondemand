# frozen_string_literal: true

require 'beaker-rspec'
require 'e2e/e2e_helper'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  c.before(:suite) do
    # Try to load cached container first
    cached = load_container_state

    # Only run setup if we didn't restore from cache
    unless cached
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
    else
      puts "Restored from cached container, skipping setup..."
      # Maybe still need to restart services
      restart_apache
      restart_dex
    end
  end

  c.after(:suite) do
    save_container_state
    dl_ctr_logs
  end
end
