module ApplicationHelper

  def json_response(object: {}, error: "", status: 200, total_pages: nil)
    render json: {
      success: is_success?(status),
      result: object,
      error_message: error,
      total_pages: total_pages
    }, status: status
  end

  def is_success?(status)
    ["2", "3"].include?(status.to_s[0])
  end

  def success_response(response_object=nil)
    json_response(object: response_object)
  end

  def unprocessable_response(exception)
    json_response(error: exception.record.errors.full_messages, status: 422)
  end

  def insufficent_funds(message = 'You do not have the funds necessary for this action')
    json_response(error: message, status: 402)
  end

  def user_not_authorized(message = 'You cannot perform this action')
    json_response(error: message, status: 403)
  end

  def not_found_response(exception)
    json_response(error: exception.message, status: 404)
  end  

  def cant_play_both_sides(short)
    message = "You already #{short ? "bought" : "shorted"} this player. Taking opp. positions in the same player is currently unavailable. We will add it soon!"
    json_response(error: message, status: 409) #409 is conflict
  end

  def render_unauthorized(realm = "Application")
    self.headers["WWW-Authenticate"] = %(Token realm="#{realm.gsub(/"/, "")}")
    json_response(error: 'Bad credentials', status: :unauthorized)
  end

end
