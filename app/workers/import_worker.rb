class ImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  def perform(id)
    import = Import.find(id)
    import.process do
      feeds = import.parse_opml
      import.create_tags(feeds)
      import.build_import_items(feeds)
    end
  end

end
