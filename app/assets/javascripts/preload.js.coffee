window.feedbin ?= {}

feedbin.summaries = {}

class feedbin.Preload
  constructor: ->
    $(document).on('ajax:beforeSend', '[data-behavior~=show_entries]', @preloadEntrySummaries)

  preloadEntrySummaries: (event) =>
    element = $(event.target)
    if @usePreloadContent(element)
      group = $(element).data('count-group')
      groupId = $(element).data('count-group-id')
      entryIds = @collectionIds(group, groupId)
      needIds = @newIds(entryIds)
      if entryIds.length > 0
        if needIds.length > 0
          $.getJSON feedbin.data.preload_summaries_entries_path, {ids: needIds.join(',')}, (data) =>
            $.extend(feedbin.summaries, data)
            @setEntriesContent(entryIds)
        else
            @setEntriesContent(entryIds)

  setEntriesContent: (entryIds) ->
    summaries = []
    $.each entryIds, (index, entryId) ->
      summaries.push(feedbin.summaries[entryId])
    summaries = summaries.join('')
    $('[data-behavior~=entries_target]').html(summaries)
    feedbin.localizeTime($('[data-behavior~=entries_target]'))
    feedbin.applyUserTitles()

  usePreloadContent: (element) ->
    feedbin.data.viewMode != "view_all" &&
    element.is('[data-behavior~=show_entries]') &&
    element.is('[data-behavior~=countable]')

  newIds: (need) ->
    have = _.keys(feedbin.summaries)
    have = _.map have, (id) ->
      id * 1
    _.difference(need, have)

  collectionIds: (group, groupId) ->
    collection = 'unread'
    if feedbin.data.viewMode == 'view_starred'
      collection = 'starred'

    ids = feedbin.Counts.get().counts[collection][group]

    if groupId
      if groupId of ids
        ids = ids[groupId]
      else
        ids = []

    ids

