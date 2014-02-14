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
  notFoundKey: 'notFound'

  el: null
  current: null

  constructor: (settings = {}) ->
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
    if typeof thing is 'function'
      console.log 'Thing is a constructor'
      thing = new thing

    if typeof thing in ['string', 'number', 'boolean']
      div = document.createElement 'div'
      div.innerHTML = thing
      thing = div.children[0]

    if 'el' of thing
      if thing.el instanceof Element
        thing = thing.el
      else if 'jquery' of thing.el
        thing = thing.el.get 0

    if thing instanceof Element
      thing

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

    params = {}

    for hash, element of @hashes
      paramsOrder = ['hash']

      hashSegments = hash.split '/'

      hashPatternSegments = for segment in hashSegments
        switch segment.charAt 0
          when ':'
            paramsOrder.push segment.slice 1
            '?([^/]*)'
          when '*'
            paramsOrder.push '_'
            '?(.*)'
          else
            segment

      params.hashPattern = "^#{hashPatternSegments.join '/'}/?$"

      matches = currentHash.match params.hashPattern

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
        @activate @hashes[@notFoundKey], params

  activate: (el, params) ->
    if @current?
      @deactivate @current, params

    @current = el

    el.setAttribute @activatedAttr, params.hash ? params.initial

    if @changeDisplay
      el.style.display = ''

    dispatchEvent el, @activateEvent , params

  deactivate: (el, params) ->
    el.removeAttribute @activatedAttr

    if @changeDisplay
      el.style.display = 'none'

    dispatchEvent el, @deactivateEvent, params

  destroy: ->
    removeEventListener 'hashchange', this, false
    @el.parentNode.removeChild @el

window.StackOfPages = StackOfPages
module?.exports = StackOfPages
