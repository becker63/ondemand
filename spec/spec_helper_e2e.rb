# frozen_string_literal: true

require 'beaker-rspec'
require 'e2e/e2e_helper'
require 'net/http'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  c.before(:suite) do
    fix_apache
    upload_portal_config('portal.yml')
    update_ood_portal
    restart_apache
    restart_dex
    bootstrap_user
    # Needed by node/rnode proxy tests
    bootstrap_flask

    # Debug: Check portal config
    puts "\n=== Checking Portal Config ==="
    on hosts, 'cat /etc/ood/config/ood_portal.yml' do |result|
      puts result.stdout
    end

    # Debug: Check Dex config
    puts "\n=== Checking Dex Config ==="
    on hosts, 'cat /etc/ood/dex/config.yaml' do |result|
      puts result.stdout
    end

    # Debug: Check Dex status
    puts "\n=== Checking Dex Status ==="
    on hosts, 'systemctl status ondemand-dex' do |result|
      puts result.stdout
      if result.stdout.include?('failed to initialize server')
        raise "Dex failed to start: #{result.stdout}"
      end
    end
  end

  c.after(:suite) do
    dl_ctr_logs
  end
end