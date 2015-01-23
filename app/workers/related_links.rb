class RelatedLinks
  include Sidekiq::Worker
  sidekiq_options retry: false, queue: :worker_slow

  def perform(entry_id)
    entry = Entry.find(entry_id)
    feed = Feed.find(entry.feed_id)

    entries = linked_entries(entry)

    cache_url(url, feed.host)
  end

  def linked_entries(entry)

    urls = PostRank::URI.extract(entry.content)
    primary_url = nil

    if entry.url.present?
      primary_url = entry.fully_qualified_url

      if primary_url =~ /(feedproxy\.google\.com|tracking\.feedpress\.it)/
        primary_url = last_effective_url(primary_url)
      end

      urls << primary_url
    end

    feed_ids = matching_feed_ids(urls)
    user_ids = Subscription.where(feed_id: entry.feed_id).pluck(:user_id)

    Subscription.where(user_id: user_ids, feed_id: feed_ids)
  end

  def matching_feed_ids(urls)
    url_hashes = urls.map do |url|
      hash_url(url)
    end

    values = $redis.pipelined do
      url_hashes.each do |url_hash|
        key = FeedbinUtils.redis_url_key(url_hash)
        $redis.hget(key, url_hash)
      end
    end

    ids = values.compact.map { |value| JSON.load(value) }.flatten.uniq
    Entry.where(id: ids).pluck(:feed_id)
  end

  def cache_url(url, host)
    url = URI.parse(url)
    if url.host.sub(/^www./, '') == host.sub(/^www./, '')

    end
  end

  def last_effective_url(url)
    result = Curl::Easy.http_head(url) do |curl|
      curl.follow_location = true
      curl.ssl_verify_peer = false
      curl.max_redirects = 5
      curl.timeout = 5
    end
    result.last_effective_url
  end

  def hash_url(url)
    url = PostRank::URI.clean(url)
    url = url.sub(/^https?\:\/\//, '').sub(/^www./,'')
    Digest::SHA1.hexdigest(url)
  end

end
