StackOfPages = window.StackOfPages

aboutBarEl = document.createElement 'div'
aboutBarEl.innerHTML = 'About bar'

class ClassifyPage extends StackOfPages._GenericPage
  textNode: document.createTextNode 'This is the classify page.'
  constructor: -> super @textNode

class ProfilePage extends StackOfPages._GenericPage
  textNode: document.createTextNode 'This is the profile.'
  constructor: -> super @textNode

class ThrowAnErrorPage extends StackOfPages._GenericPage
  textNode: document.createTextNode()
  constructor: -> super @textNode
  activate: ->
    throw new Error "This is an error thrown from the `activate` method."

  deactivate: (params) ->
    return unless params?
    console.log 'Deactivating error page'

class DisplayErrorPage extends StackOfPages._GenericPage
  textNode: document.createTextNode()
  constructor: -> super @textNode
  activate: (params) ->
    console.log 'Error page got an error:', params.error.toString()
    @el.innerHTML = """
      There was an error.<br />
      <code>#{JSON.stringify params}</code><br />
      <br />
      Check the console for the actual error.
    """

window.stack = new StackOfPages
  '#/': 'Home' # Given a string
  '#/about/*': new StackOfPages # Given another instance of StackOfPages
    '#/about/foo': 'About foo'
    '#/about/bar': aboutBarEl # Given an HTML element
    DEFAULT: '#/about/foo'
  '#/classify': ClassifyPage # Given a class
  '#/profile': new ProfilePage # Given an instance of a class
  '#/throw-an-error': ThrowAnErrorPage # Test errors
  ERROR: DisplayErrorPage
  NOT_FOUND: 'Not found!'

document.body.appendChild window.stack.el
