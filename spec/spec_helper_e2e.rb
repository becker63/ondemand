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

    # Add wait loop for Dex to be ready
    uri = URI('http://localhost:5556/.well-known/openid-configuration')
    Timeout.timeout(30) do
      loop do
        begin
          resp = Net::HTTP.get_response(uri)
          break if resp&.code == '200'
        rescue StandardError
          # service not up yet
        end
        sleep 1
      end
    end
    
    # Add debug output
    on hosts, 'systemctl status ondemand-dex' do
      puts "Dex status: #{stdout}"
    end
    on hosts, 'curl -v http://localhost:5556/.well-known/openid-configuration' do
      puts "Dex response: #{stdout}"
    end
  end

  c.after(:suite) do
    dl_ctr_logs
  end
end