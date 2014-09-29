window.feedbin ?= {}

class feedbin.MarkRead
  constructor: ->
    @markReadButton = $('[data-behavior~=mark_all_as_read]')
    $(document).on('feedbin:deselectFeed', @deselectFeed)
    $(document).on('click', '[data-behavior~=show_entries]', @selectFeed)
    $(document).on('click', '[data-behavior~=mark_all_as_read]', @markAllRead)
    $(document).on('click', '[data-behavior~=mark_below_read], [data-behavior~=mark_above_read]', @markDirectionRead)

  selectFeed: (event) =>
    @feed = $(event.currentTarget).data()
    if @feed.countGroup
      @markReadButton.removeAttr('disabled')
    else
      @markReadButton.attr('disabled', 'disabled')

  deselectFeed: (event) =>
    @feed = {}
    @markReadButton.attr('disabled', 'disabled')

  markAllRead: (event) =>
    unless $(@).attr('disabled')
      ids = feedbin.Counts.get().getUnreadIds(@feed.countGroup, @feed.countGroupId)
      if feedbin.data.mark_as_read_confirmation
        result = confirm(@feed.markReadMessage)
        if result
          @markRead(ids)
          $('.entries li').addClass('read')
      else
        @markRead(ids)
        $('.entries li').addClass('read')

  markDirectionRead: (event) =>
    entry = $(event.currentTarget)
    ids = $(entry).parents('li').prevAll().map(() ->
      $(@).data('entry-id')
    ).get()

    if $(entry).is('[data-behavior~=mark_below_read]')
      allIds = feedbin.Counts.get().getUnreadIds(@feed.countGroup, @feed.countGroupId)
      ids = _.difference(allIds, ids);
      $(entry).parents('li').nextAll().addClass('read')
    else
      $(entry).parents('li').prevAll().addClass('read')

    @markRead(ids)

  markRead: (ids) ->
    if ids.length > 0
      feedbin.Counts.get().bulkRemoveUnread(ids)
      feedbin.applyCounts(true)
      data = {ids: ids}
      $.ajax
        url: feedbin.data.mark_as_read_path
        type: 'POST'
        data: JSON.stringify(data)
        contentType: 'application/json; charset=utf-8'