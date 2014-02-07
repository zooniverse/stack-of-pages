StackOfPages = window.StackOfPages

toElement = (string) ->
  div = document.createElement 'div'
  div.id = string
  div.innerHTML = "<h1>#{string}</h1><p>#{string.split('').join '<br />'}</p>"
  div

window.stack = new StackOfPages
  '#/': toElement 'Home'
  '#/about/:topic': new StackOfPages
    '#/about/foo': toElement 'About-foo'
    '#/about/bar': toElement 'About-bar'
    default: '#/about/foo'
  '#/classify': toElement 'Classify'
  '#/profile': toElement 'Profile'
  notFound: toElement 'Not-found'

document.body.appendChild window.stack.el
