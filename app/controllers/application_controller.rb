class ApplicationController < ActionController::Base
  include ApplicationHelper
  include ActionController::MimeResponds
  respond_to :html, :json

  def after_sign_in_path_for(resource)
    return admin_root_url if resource.is_a? AdminUser
    root_url
  end
end
