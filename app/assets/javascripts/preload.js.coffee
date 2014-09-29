window.feedbin ?= {}

feedbin.entrySummaries = {}

class feedbin.Preload
  constructor: ->
    $(document).on('ajax:beforeSend', '[data-behavior~=show_entries]', @preloadEntrySummaries)

  preloadEntrySummaries: (event) =>
    element = $(event.target)
    if @usePreloadContent(element)
      if feedbin.data.viewMode == "view_unread"
        console.log 'elemnt', element

  usePreloadContent: (element) ->
    feedbin.data.viewMode != "view_all" &&
    element.is('[data-behavior~=show_entries]') &&
    element.is('[data-behavior~=countable]')