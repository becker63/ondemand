# frozen_string_literal: true

require 'beaker-rspec'
require 'e2e/e2e_helper'

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
  end

  c.after(:suite) do
    dl_ctr_logs
  end
end