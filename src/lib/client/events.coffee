###
conf.io
author: gordon hall

events.coffee - sockets init
###

bind = (socket) ->

  # on client connect
  socket.on "joined-conference", (data) ->
    console.log "new participant"

module.exports = bind : bind
