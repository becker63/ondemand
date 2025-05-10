# frozen_string_literal: true

require 'beaker-rspec'
require 'e2e/e2e_helper'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  c.before(:suite) do
    cached = load_container_state

    if cached
      puts "\n=== CACHED PATH ==="
      puts "Restored from cached container with OnDemand installed..."

      puts "\n=== Installing Apache ==="
      if apt?
        install_packages(['apache2'])
      else
        install_packages(['httpd'])
      end

      puts "\n=== Fixing Apache ==="
      fix_apache

      puts "\n=== Checking directory state ==="
      on hosts, 'ls -l /etc/ood && ls -l /etc/ood/config || echo "no config dir"'

      puts "\n=== Uploading portal config ==="
      upload_portal_config('portal.yml')

      puts "\n=== Updating OOD portal ==="
      update_ood_portal

      puts "\n=== Restarting Apache ==="
      restart_apache

      puts "\n=== Restarting Dex ==="
      restart_dex
    else
      puts "\n=== FRESH INSTALL PATH ==="
      puts "No cached container found, running full setup..."

      puts "\n=== Bootstrapping repos ==="
      bootstrap_repos

      puts "\n=== Setting up OnDemand repo ==="
      ondemand_repo

      puts "\n=== Installing OnDemand ==="
      install_ondemand

      puts "\n=== Checking directory state ==="
      on hosts, 'ls -l /etc/ood && ls -l /etc/ood/config || echo "no config dir"'

      puts "\n=== Saving container state ==="
      save_container_state

      puts "\n=== Fixing Apache ==="
      fix_apache

      puts "\n=== Uploading portal config ==="
      upload_portal_config('portal.yml')

      puts "\n=== Updating OOD portal ==="
      update_ood_portal

      puts "\n=== Restarting Apache ==="
      restart_apache

      puts "\n=== Restarting Dex ==="
      restart_dex

      puts "\n=== Bootstrapping user ==="
      bootstrap_user

      puts "\n=== Bootstrapping Flask ==="
      bootstrap_flask
    end
  end

  c.after(:suite) do
    puts "\n=== Downloading container logs ==="
    dl_ctr_logs
  end
end
