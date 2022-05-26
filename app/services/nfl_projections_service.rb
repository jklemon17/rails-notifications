class NflProjectionsService

  def initialize
    @s3 = Aws::S3::Client.new({
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    })
    @bucket = 'prediction-endpoint'
    @key = 'predictions.json'
  end

  def get_data
    predictions_file = @s3.get_object(bucket: @bucket, key: @key)
    JSON.parse(predictions_file.body.read)
  end

end
