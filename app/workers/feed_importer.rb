class FeedImporter
  include Sidekiq::Worker
  sidekiq_options queue: :critical, retry: false

  def perform(import_item_id)
    import_item = ImportItem.find(import_item_id)

    user = import_item.import.user
    result = FeedFetcher.new(import_item.details[:xml_url], import_item.details[:html_url]).create_feed!
    if result.feed
      subscription = user.safe_subscribe(result.feed)
      if import_item.details[:title] && subscription
        subscription.title = import_item.details[:title]
        subscription.save
      end
      if import_item.details[:tag]
        result.feed.tag(import_item.details[:tag], user, false)
      end
    end
  end

end
