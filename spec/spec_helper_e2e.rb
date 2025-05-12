# frozen_string_literal: true

require 'beaker-rspec'
require 'e2e/e2e_helper'
require 'net/http'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  c.before(:suite) do
    bootstrap_repos
    ondemand_repo
    install_ondemand
    fix_apache
    upload_portal_config('portal.yml')
    update_ood_portal
    restart_apache
    restart_dex
    bootstrap_user
    # Needed by node/rnode proxy tests
    bootstrap_flask

    # Debug: Check Dex config first
    puts "\n=== Checking Dex Config ==="
    on hosts, 'cat /etc/ood/dex/config.yaml' do |result|
      puts result.stdout
    end

    # Debug: Check Dex status and logs
    puts "\n=== Checking Dex Status ==="
    on hosts, 'systemctl status ondemand-dex' do |result|
      puts result.stdout
      if result.stdout.include?('failed to initialize server')
        raise "Dex failed to start: #{result.stdout}"
      end
    end

    puts "\n=== Checking Dex Logs ==="
    on hosts, 'journalctl -u ondemand-dex --no-pager' do |result|
      puts result.stdout
    end
  end

  c.after(:suite) do
    dl_ctr_logs
  end
end