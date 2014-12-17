class ImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  def perform(id)
    import = Import.find(id)
    extension = import.upload.file.extension.downcase
    import.build_opml_import_job
  end

end
