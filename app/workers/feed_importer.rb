class FeedImporter
  include Sidekiq::Worker
  sidekiq_options queue: :critical, retry: false

  def perform(import_item_id)
    import_item = ImportItem.find(import_item_id)
    user = import_item.import.user

    feed = Feed.where(feed_url: import_item.details[:xml_url])
    if feed.blank?
      feed = create_feed(import_item.details[:xml_url], import_item.details[:html_url])
    end

    user.subscriptions.where(feed: feed).first_or_create!(title: import_item.details[:title])

    if import_item.details[:tag]
      feed.tag(import_item.details[:tag], user, false)
    end

  end

  def create_feed(feed_url, site_url)
    feed_parser = FeedParser.new(feed_url)
    parsed_feed = feed_parser.fetch_and_parse
    Feed.create!(parsed_feed.to_h, site_url)
  end

end
