module PlaybookApi
  class Application < Rails::Application
    config.email_templates_sendgrid_signup = 'd-3a46536f088d46d4bf5fec2ecc975ea8'
    config.email_templates_sendgrid_refund_injured = 'd-1cafbd19c58f4244b9c8b4f8f7ceb2e3'
    config.email_templates_sendgrid_not_compliant_warning = 'd-272204ab47f241a89a51b63c50f3ebdb'
    config.email_templates_sendgrid_not_compliant_refund = 'd-65a004497a384375bcbeb0ea14dea6fd'
    config.email_templates_sendgrid_reset_password = 'd-a705d863e9d54dd59c9cc05017686741'
    config.email_templates_sendgrid_deposit = 'd-53919d9933bb4c5aa47856a06e46902e'
    config.email_templates_sendgrid_withdraw = 'd-9e5a375eee40403086412674d6088a5f'
  end
end
