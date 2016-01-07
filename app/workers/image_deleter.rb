class ImageDeleter
  include Sidekiq::Worker

  FOG_POOL = ConnectionPool.new(size: 4, timeout: 500) do
    Fog::Storage.new(provider: 'AWS', aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"], aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
  end

  def perform(images)
    FOG_POOL.with do |connection|
      connection.delete_multiple_objects(ENV["AWS_S3_BUCKET"], images, {quiet: true})
    end
    Librato.increment 'entry_image.delete', by: images.length
  end

end
