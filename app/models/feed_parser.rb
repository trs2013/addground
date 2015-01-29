class FeedParser

  def initialize(feed_url)
    @feed_url = feed_url
  end

  def fetch_and_parse(@feed_url, options = {}, base_feed_url = nil)
    defaults = {user_agent: 'Feedbin', ssl_verify_peer: false, timeout: 20}
    options = defaults.merge(options)
    feed = Feedjira::Feed.fetch_and_parse(feed_url, options)
    if is_feed?(feed)
      feed = normalize(feed, base_feed_url)
    end
    feed
  end

  private

  def is_feed?(feed)
    feed.class.name.starts_with?('Feedjira')
  end

  def normalize(feed, base_feed_url)
    feed.etag          = feed.etag ? feed.etag.strip.gsub(/^"/, '').gsub(/"$/, '') : nil
    feed.last_modified = feed.last_modified
    feed.title         = feed.title ? feed.title.strip : '(No title)'
    feed.feed_url      = feed.feed_url.strip
    feed.url           = get_site_url(feed)
    feed.entries.map do |entry|
      entry.content     = get_content(entry)
      entry.author      = entry.author ? entry.author.strip : nil
      entry.content     = content ? content.strip : nil
      entry.title       = entry.title ? entry.title.strip : nil
      entry.url         = entry.url ? entry.url.strip : nil
      entry.entry_id    = entry.entry_id ? entry.entry_id.strip : nil
      entry._public_id_ = build_public_id(entry, feed, base_feed_url)
      entry._data_      = get_data(entry)
    end
    feed.entries = unique_entries(feed.entries)
    feed
  end

  def get_site_url(feed)
    if feed.url.present?
      url = feed.url
    else
      if feed.feed_url =~ /feedburner\.com/
        url = expand_link(feed.entries.first.url)
        url = url_from_host(url)
      else
        url = url_from_host(feed.feed_url)
      end
    end
    url
  end

  def url_from_host(link)
    uri = URI.parse(link)
    URI::HTTP.build(host: uri.host).to_s
  end

  def get_content(entry)
    content = nil
    if entry.try(:content)
      content = entry.content
    elsif entry.try(:summary)
      content = entry.summary
    elsif entry.try(:description)
      content = entry.description
    end
    content
  end

  def get_data(entry)
    data = {}
    if entry.try(:enclosure_type) && entry.try(:enclosure_url)
      data[:enclosure_type] = entry.enclosure_type ? entry.enclosure_type : nil
      data[:enclosure_url] = entry.enclosure_url ? entry.enclosure_url : nil
      data[:enclosure_length] = entry.enclosure_length ? entry.enclosure_length : nil
      data[:itunes_duration] = entry.itunes_duration ? entry.itunes_duration : nil
    end
    data
  end

  def unique_entries(entries)
    entries = nil
    if entries.any?
      entries = feed.entries.uniq { |entry| entry._public_id_ }
    end
    entries
  end

  # This is the id strategy
  # All values are stripped
  # feed url + id
  # feed url + link + utc iso 8601 date
  # feed url + link + title

  # WARNING: changes to this will break how entries are identified
  # This can only be changed with backwards compatibility in mind
  def build_public_id(entry, feedjira, base_feed_url = nil)
    if base_feed_url
      id_string = base_feed_url.dup
    else
      id_string = feedjira.feed_url.dup
    end

    if entry.entry_id
      id_string << entry.entry_id.dup
    else
      if entry.url
        id_string << entry.url.dup
      end
      if entry.published
        id_string << entry.published.iso8601
      end
      if entry.title
        id_string << entry.title.dup
      end
    end
    Digest::SHA1.hexdigest(id_string)
  end

end
