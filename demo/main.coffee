StackOfPages = window.StackOfPages

class ClassifyPage
  constructor: ->
    @el = document.createElement 'div'
    @el.innerHTML = 'This is the classify page.'

class ProfilePage
  constructor: ->
    @el = document.createElement 'div'
    @el.innerHTML = 'This is the profile.'

window.stack = new StackOfPages
  hashes:
    '#/': 'Home' # Given a string
    '#/about/*': new StackOfPages # Given another instance of StackOfPages
      default: '#/about/foo'
      hashes:
        '#/about/foo': 'About foo'
        '#/about/bar': 'About bar'
    '#/classify': ClassifyPage # Given a class
    '#/profile': new ProfilePage # Given an instance of a class

    ERROR: 'ERROR!'
    NOT_FOUND: 'Not found!'

document.body.appendChild window.stack.el
