dispatchEvent = (element, eventName, detail) ->
  e = document.createEvent 'CustomEvent'
  e.initCustomEvent eventName, true, true, detail
  element.dispatchEvent e

recentClick = false

forgetClick = ->
  recentClick = false

onClick = ->
  recentClick = true
  setTimeout forgetClick, 50

addEventListener 'click', onClick, false

scrollOffsets = {}

onScroll = ->
  scrollOffsets[location.hash] = x: pageXOffset, y: pageYOffset

addEventListener 'scroll', onScroll, false

class StackOfPages
  hashes: null
  default: '#/'

  tagName: 'div'
  className: 'stack-of-pages'

  changeDisplay: true
  activatedAttr: 'data-active-in-stack'
  hashRootAttr: 'data-location-hash'
  activateEvent: 'activate-in-stack'
  deactivateEvent: 'deactivate-in-stack'
  notFoundKey: 'NOT_FOUND'

  el: null
  current: null

  constructor: (settings) ->
    @el ?= document.createElement @tagName
    @el.className = @className

    @hashes = {}

    for key, value of settings
      if key.charAt(0) is '#' or key is @notFoundKey
        @add key, value
      else
        @[key] = value

    addEventListener 'hashchange', this, false

    @onHashChange()

    unless @current?
      if @default of @hashes
        @activate @hashes[@default], initial: true

  add: (hash, thing) ->
    element = @findElement thing

    if element?
      if hash?
        @hashes[hash] = element

      @el.appendChild element

      @deactivate element, initial: true
    else
      throw new Error "Couldn't determine element for #{hash}"

  findElement: (thing) ->
    if thing instanceof Element
      thing
    else
      if typeof thing is 'function'
        instance = new thing
        instance.el
      else if typeof thing in ['string', 'number', 'boolean']
        el = document.createElement @tagName
        el.innerHTML = thing
        el
      else if 'jQuery' of window and thing instanceof jQuery
        thing.get 0
      else
        thing.el

  handleEvent: (e) ->
    handler = switch e.type
      when 'hashchange' then @onHashChange

    handler?.apply this, arguments

  onHashChange: ->
    currentHash = location.hash || @default

    if recentClick or currentHash not of scrollOffsets
      scrollOffsets[currentHash] = x: 0, y: 0

    {x, y} = scrollOffsets[currentHash]

    setTimeout ->
      scrollTo x, y

    foundMatch = false

    for hash, element of @hashes
      paramsOrder = ['hash']

      hashSegments = hash.split '/'

      hashPatternSegments = for segment in hashSegments
        switch segment.charAt 0
          when ':'
            paramsOrder.push segment.slice 1
            '([^\/]+)'
          when '*'
            paramsOrder.push '_'
            '?(.*)'
          else
            segment

      hashPattern = "^#{hashPatternSegments.join '/'}/?$"
      params = {hashPattern}

      matches = currentHash.match hashPattern

      if matches?
        foundMatch = true

        for param, i in paramsOrder
          params[param] = matches[i]

        @activate element, params
        document.body.parentNode.setAttribute @hashRootAttr, hash

      break if foundMatch

    unless foundMatch
      params.notFound = true
      if @notFoundKey of @hashes
        @activate @hashes.NOT_FOUND, params

  activate: (el, params) ->
    console.log 'activating', el
    if @current?
      @deactivate @current, params

    @current = el

    el.setAttribute @activatedAttr, params.hash ? params.initial

    if @changeDisplay
      el.style.display = ''

    unless params.initial
      dispatchEvent el, @activateEvent , params

  deactivate: (el, params) ->
    el.removeAttribute @activatedAttr

    if @changeDisplay
      el.style.display = 'none'

    unless params.initial
      dispatchEvent el, @deactivateEvent, params

  destroy: ->
    removeEventListener 'hashchange', this, false
    @el.parentNode.removeChild @el

window.StackOfPages = StackOfPages
module?.exports = StackOfPages
