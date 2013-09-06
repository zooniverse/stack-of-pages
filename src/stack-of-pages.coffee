class StackOfPages
  class Page
    el: null

    constructor: (content) ->
      @el = document.createElement 'div'
      @el.className = 'page-in-a-stack'
      @el.innerHTML = content

  default: '#/'
  hashes: null

  tagName: 'div'
  className: 'stack-of-pages'

  activeClass: 'active'
  inactiveClass: 'inactive'
  changeDisplay: true

  elProperties: ['el']

  el: null
  activeController: null

  constructor: (params = {}) ->
    @[property] = value for property, value of params
    @el = document.createElement @tagName
    @el.className = @className

    for hash, preControllerThing of @hashes
      controller = if typeof preControllerThing is 'function'
        new preControllerThing
      else if typeof preControllerThing is 'string'
        new Page preControllerThing
      else if 'jquery' of preControllerThing
        preControllerThing.get 0
      else preControllerThing

      @hashes[hash] = controller

      controllerEl = @getElOfController controller
      controllerEl =  controllerEl.get 0 if 'jquery' of controllerEl

      controllerEl.setAttribute 'data-stack-of-pages-hash', hash
      @el.appendChild controllerEl

    addEventListener 'hashchange', @onHashChange
    @onHashChange()

  onHashChange: =>
    @activeController?.deactivate?
    currentHash = location.hash || @default

    foundMatch = false

    for hash, controller of @hashes
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

      controllerEl = @el.querySelector "[data-stack-of-pages-hash='#{hash}']"

      if matches?
        foundMatch = true

        params = {hashPattern}
        for param, i in paramsOrder
          params[param] = matches[i]

        try
          @activatePage controller, params
        catch e
          if 'ERROR' of @hashes
            params.error = e
          else
            throw e

      else
        @deactivatePage controller, params

    if params?.error?
      @activatePage @hashes.ERROR, params

    unless foundMatch
      @activatePage @hashes.NOT_FOUND, params if 'NOT_FOUND' of @hashes

  activate: (params) ->
    unless params.hash of @hashes
      @activatePage @hashes[@default] if @default of @hashes

  getElOfController: (controller) ->
    (controller[property] for property in @elProperties when controller[property]?)[0]

  activatePage: (controller, params) ->
    controllerEl = @getElOfController controller
    controllerEl.style.display = '' if @changeDisplay
    @toggleClass controllerEl, @activeClass, true
    @toggleClass controllerEl, @inactiveClass, false
    controller.activate? params

  deactivatePage: (controller, params) ->
    controllerEl = @getElOfController controller
    controllerEl.style.display = 'none' if @changeDisplay
    @toggleClass controllerEl, @activeClass, false
    @toggleClass controllerEl, @inactiveClass, true
    controller.deactivate? params

  toggleClass: (el, className, condition) ->
    classList = el.className.split /\s+/
    alreadyThere = className in classList

    if condition and not alreadyThere
      classList.push className

    if not condition and alreadyThere
      classList.splice (classList.indexOf className), 1

    el.className = classList.join ' '

window.StackOfPages = StackOfPages
module?.exports = StackOfPages
