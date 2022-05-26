require 'uri'
require 'net/http'
require 'openssl'

class TsevoService
  def initialize(endpoint)
    @url = URI(endpoint)
    @api_key = ENV['TSEVO_API_KEY']
    @merchant_id = ENV['TSEVO_MERCHANT_ID']
    @product_type_id = ENV['TSEVO_PRODUCT_ID']
    @device_type_id = ENV['TSEVO_DEVICE_ID']
    @activity_id = ENV['TSEVO_ACTIVITY_ID']
    @http = Net::HTTP.new(@url.host, @url.port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def validate_identity(user)
    # CLIENT DOESNT WANT TO VALIDATE IDENTITY UNTIL FIRST DEPOSIT BUILT INTO DEPOSIT FLOW
    body = {
        "ApiKey": @api_key,
        "MerchantID": @merchant_id,
        "ProductTypeID": @product_type_id,
        "DeviceTypeID": @device_type_id,
        "ActivityTypeID": @activity_id,
        "MerchantSessionID": user.id,
        # -------------------------
        # "DeviceIpAddress":'192.168.1.163', # need to pass this from front-end
        "MerchantCustomerID": user.id,
        "FirstName": user.first_name,
        "LastName": user.last_name,
        "DateOfBirth": user.date_of_birth,
        "EmailAddress": user.email,

        # there are other fields but they are not required. the more fields we ask for the more likely the user will be approved but it creates onboarding friction
        # other fields:
            # "MobilePhoneNumber"
            # "PhoneNumber"
            # "Address"
            # "IdentificationTypeCode" (drivers license, SSN)
            # "IdentificationNumber" (drivers license, SSN)
    }
    request = Net::HTTP::Post.new(@url.path, 'Content-Type'  => 'application/json;charset=utf-8',)
    request.body = body.to_json
    response = @http.request(request)
    return user.update(tsevo_status: 1) if response.body.ResponseCode == 0
	    # Just because someone fails initially does not mean necessarily anything. The webview will know to ask for more information if more is required on first deposit. 
	    user.update(tsevo_status: 2)
	    response.body.ResponseMessage
  end
  
  def payment_details(transaction_id, session_token)
    @current_user = User.find_by(jti: JWT.decode(session_token, Rails.application.credentials.jwt_secret_key,"H256")[0]["jti"])
    body = {
      "ApiKey": @api_key,
      "MerchantID": @merchant_id,
      "ProductTypeID": @product_type_id,
      "DeviceTypeID": @device_type_id,
      "ActivityTypeID": @activity_id,
      "MerchantSessionID": session_token,
      "MerchantTransactionID": transaction_id
    }
    request = Net::HTTP::Post.new(@url.path, 'Content-Type'  => 'application/json;charset=utf-8',)
    request.body = body.to_json
    response = @http.request(request)

    update_balances(response, @current_user)
  end
  
  def get_updated_transaction_status(transaction_id)
    @transaction = Transaction.find(transaction_id)
    @user = @transaction.user
    failed_payment_codes = [2, 3, 5, 6]
    jwt = JWT.encode({'jti' => @user.jti, 
                      'exp' => Time.now.to_i + 2.minutes.to_i, 
                      'iat' => Time.now.to_i},
                      Rails.application.credentials.jwt_secret_key, "HS256")

    body = {
        "ApiKey": @api_key,
        "MerchantID": @merchant_id,
        "ProductTypeID": @product_type_id,
        "DeviceTypeID": @device_type_id,
        "ActivityTypeID": @activity_id,
        "MerchantSessionID": jwt,
        "MerchantTransactionID": transaction.id
    }
    request = Net::HTTP::Post.new(@url.path, 'Content-Type'  => 'application/json;charset=utf-8',)
    request.body = body.to_json
    response = @http.request(request)

    update_balances(response, @user)
  end

  def update_balances(response, user)
    status = 0
    amount = 0
    bonus_amount = 0
    response["PaymentDetails"].each do |payment|
    if response["PaymentAmountType"] == 'CREDIT'
        if payment["PaymentAmountCode"] == 'Bonus'
          bonus_amount = payment["PaymentAmount"] * 100
          user.update(bonus_balance: user.bonus_balance + bonus_amount) if payment["PaymentStatusCode"] == 1
        elsif (payment["PaymentAmountCode"] == 'Sale')
          amount = payment["PaymentAmount"] * 100
          status = payment["PaymentStatusCode"]
          user.update(unplayed_deposits: user.unplayed_deposits + amount) if status == 1
        end
      else
        status = payment["PaymentStatusCode"]
        amount = payment["PaymentAmount"] * 100
        user.update(winnings: winnings - amount) if status == 1
      end
    end

    return { status: status, 
             amount: amount, 
             bonus_amount: bonus_amount }
  end
  
end
