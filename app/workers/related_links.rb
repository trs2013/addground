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
    primary_url = entry.fully_qualified_url

    if primary_url =~ /(feedproxy\.google\.com|tracking\.feedpress\.it)/
      primary_url = last_effective_url(primary_url)
    end

    urls = PostRank::URI.extract(entry.content)
    urls << primary_url

    urls = urls.map do |url|
      normalize_url(url)
    end

    ids = $redis.pipelined do
      urls.each do |hash|
        key = FeedbinUtils.redis_url_key(hash)
        $redis.hget(key, hash)
      end
    end


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

  def normalize_url(url)
    url = PostRank::URI.clean(url)
    url = url.sub(/^https?\:\/\//, '').sub(/^www./,'')
    Digest::SHA1.hexdigest(url)
  end

end
