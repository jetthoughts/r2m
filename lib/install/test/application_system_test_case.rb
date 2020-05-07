# frozen_string_literal: true

require 'test_helper'
require 'capybara/minitest/spec'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  TUNING_CHROME_ARGS = %w[
    --disable-background-timer-throttling --disable-backgrounding-occluded-windows
    --disable-breakpad --disable-component-extensions-with-background-pages
    --disable-dev-shm-usage --disable-extensions --disable-features=TranslateUI,BlinkGenPropertyTrees
    --disable-gpu --disable-infobars --disable-ipc-flooding-protection --disable-popup-blocking
    --disable-renderer-backgrounding --disable-site-isolation-trials --disable-web-security
    --enable-features=NetworkService,NetworkServiceInProcess --force-color-profile=srgb
    --force-device-scale-factor=1 --hide-scrollbars --metrics-recording-only --mute-audio --no-sandbox
  ].freeze

  driven_by :selenium, using: :headless_chrome do |options|
    TUNING_CHROME_ARGS.each do |arg|
      options.add_argument arg
    end
  end
end
