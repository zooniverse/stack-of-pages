exec = require 'easy-exec'

DEFAULT_PORT = 4635

task 'serve', ->
  exec 'coffee --compile --output . --watch ./src'
  exec "silver server --port #{process.env.PORT || DEFAULT_PORT}"
