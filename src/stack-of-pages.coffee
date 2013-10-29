class StackOfPages
  class @_GenericPage
    constructor: (content) ->
      @el = document.createElement 'div'
      @el.className = 'generic-page-in-a-stack'
      if content.nodeType?
        @el.appendChild content
      else
        @el.innerHTML = content

  hashes: null # Special keys are "DEFAULT", "NOT_FOUND", and "ERROR"
  default: '#/'

  tagName: 'div'
  className: 'stack-of-pages'

  activeClass: 'active'
  inactiveClass: 'inactive'
  changeDisplay: true

  hashRootAttr: 'data-location-hash'

  pageElProperties: ['el']

  el: null
  activePage: null

  recentClick: false
  scrollOffsets: null

  constructor: (@hashes = {}, params = {}) ->
    # Did we only pass in an options object?
    [@hashes, params] = [null, @hashes] if 'hashes' of @hashes

    @[property] = value for property, value of params

    @hashes ?= {}

    @default = @hashes.DEFAULT if 'DEFAULT' of @hashes

    @el ?= document.createElement @tagName
    @_toggleClass @el, @className, true

    @scrollOffsets ?= {}

    for hash, preTarget of @hashes
      target = if typeof preTarget is 'function'
        new preTarget
      else if preTarget.nodeType? or typeof preTarget in ['string', 'number']
        new @constructor._GenericPage preTarget
      else
        preTarget

      el = (target[property] for property in @pageElProperties when target[property]?)[0]
      el ?= target
      el = el.get 0 if 'jquery' of el

      @hashes[hash] = {target, el}

      @deactivatePage @hashes[hash]

      @el.appendChild el

    addEventListener 'click', @onClick, false
    addEventListener 'scroll', @onScroll, false
    addEventListener 'hashchange', @onHashChange, false

    @onHashChange()

  onClick: (e) =>
    # If a link was recently clicked, we'll ignore the scroll offset.
    @recentClick = true
    setTimeout => @recentClick = false

  onScroll: =>
    @scrollOffsets[location.hash] = [pageXOffset, pageYOffset]

  onHashChange: =>
    currentHash = location.hash || @default

    foundMatch = false
    for hash, targetAndEl of @hashes
      paramsOrder = ['hash']

      hashSegments = hash.split '/'

      hashPatternSegments = for segment in hashSegments
        switch segment.charAt 0
          when ':'
            paramsOrder.push segment[1...]
            '([^\/]+)'
          when '*'
            paramsOrder.push '_'
            '?(.*)'
          else
            segment

      hashPattern = "^#{hashPatternSegments.join '/'}/?$"

      matches = currentHash.match hashPattern

      if matches?
        foundMatch = true

        params = {hashPattern}
        for param, i in paramsOrder
          params[param] = matches[i]

        try
          @activatePage targetAndEl, params
          document.body.parentNode.setAttribute @hashRootAttr, hash
        catch e
          if 'ERROR' of @hashes
            params.error = e
          else
            throw e

    if params?.error?
      @activatePage @hashes.ERROR, params

    unless foundMatch
      @activatePage @hashes.NOT_FOUND, params if 'NOT_FOUND' of @hashes

    unless @recentClick then setTimeout =>
      [x, y] = @scrollOffsets[location.hash] || [0, 0]
      scrollTo x, y

  activate: (params) ->
    unless params.hash of @hashes
      @activatePage @hashes[@default] if @default of @hashes

  activatePage: ({target, el}, params...) ->
    unless @activePage?.target is target
      @deactivatePage @activePage, params... if @activePage?
      @activePage = {target, el}

    el.style.display = '' if @changeDisplay
    @_toggleClass el, @activeClass, true
    @_toggleClass el, @inactiveClass, false
    target.activate? params...

  deactivatePage: ({target, el}, params...) ->
    el.style.display = 'none' if @changeDisplay
    @_toggleClass el, @activeClass, false
    @_toggleClass el, @inactiveClass, true
    target.deactivate? params...

  _toggleClass: (el, className, condition) ->
    classList = el.className.split /\s+/
    alreadyThere = className in classList

    if condition and not alreadyThere
      classList.push className

    if not condition and alreadyThere
      classList.splice (classList.indexOf className), 1

    el.className = classList.join ' '

  destroy: ->
    removeEventListener 'click', @onClick, false
    removeEventListener 'scroll', @onScroll, false
    removeEventListener 'hashchange', @onHashChange, false
    target.destroy? arguments... for hash, {target} of @hashes
    @el.parentNode.removeChild @el

window.StackOfPages = StackOfPages
module?.exports = StackOfPages
