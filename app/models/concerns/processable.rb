module Processable
  extend ActiveSupport::Concern

  def mark_failed(error)
    update_attributes(status: Import.statuses[:failed], error: error.to_s)
  end

  def process(cleanup = nil)
    processing!
    yield
    success!
  rescue => exception
    mark_failed(exception)
  end

end