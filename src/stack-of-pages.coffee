class StackOfPages
  class @_GenericPage
    constructor: (@textNode) ->
      @el = document.createElement 'div'
      @el.className = 'generic-page-in-a-stack'
      @el.appendChild @textNode

  default: '#/' # Also set via @hashes.DEFAULT
  hashes: null

  tagName: 'div'
  className: 'stack-of-pages'

  activeClass: 'active'
  inactiveClass: 'inactive'
  changeDisplay: true

  pageElProperties: ['el']

  el: null
  activePage: null

  constructor: (@hashes = {}, params = {}) ->
    [@hashes, params] = [null, @hashes] if 'hashes' of @hashes

    @[property] = value for property, value of params
    if 'DEFAULT' of hashes
      @default = @hashes.DEFAULT

    @el = document.createElement @tagName
    @el.className = @className

    for hash, preTarget of @hashes
      target = if typeof preTarget is 'function'
        new preTarget
      else if preTarget instanceof HTMLElement
        new @constructor._GenericPage preTarget
      else if (typeof preTarget in ['string', 'number'])
        new @constructor._GenericPage document.createTextNode preTarget
      else
        preTarget

      el = if 'jquery' of target
        target.get 0
      else
        (target[property] for property in @pageElProperties when target[property]?)[0]

      @hashes[hash] = {target, el}

      @deactivatePage @hashes[hash]

      @el.appendChild el

    addEventListener 'hashchange', @onHashChange
    @onHashChange()

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
        catch e
          if 'ERROR' of @hashes
            params.error = e
          else
            throw e

    if params?.error?
      @activatePage @hashes.ERROR, params

    unless foundMatch
      @activatePage @hashes.NOT_FOUND, params if 'NOT_FOUND' of @hashes

  activate: (params) ->
    unless params.hash of @hashes
      @activatePage @hashes[@default] if @default of @hashes

  activatePage: ({target, el}, params) ->
    unless @activePage?.target is target
      @deactivatePage @activePage, params if @activePage?
      @activePage = {target, el}

    el.style.display = '' if @changeDisplay
    @_toggleClass el, @activeClass, true
    @_toggleClass el, @inactiveClass, false
    target.activate? params

  deactivatePage: ({target, el}, params) ->
    el.style.display = 'none' if @changeDisplay
    @_toggleClass el, @activeClass, false
    @_toggleClass el, @inactiveClass, true
    target.deactivate? params

  _toggleClass: (el, className, condition) ->
    classList = el.className.split /\s+/
    alreadyThere = className in classList

    if condition and not alreadyThere
      classList.push className

    if not condition and alreadyThere
      classList.splice (classList.indexOf className), 1

    el.className = classList.join ' '

window.StackOfPages = StackOfPages
module?.exports = StackOfPages
