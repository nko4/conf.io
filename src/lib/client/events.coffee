###
conf.io
author: gordon hall

events.coffee - sockets init
###

classes = require "./classes.coffee"

bind = (socket) ->

  # on client connect
  socket.on "joined-conference", (data) ->
    # create a new user instance
    Conf.user = new classes.User
      uuid: localStorage.getItem "user-uuid"
      socket: socket
      stream: new classes.AVStream()
      transcript: new classes.Transcript()

    # open stream to other is presenter
    Conf.user.isPresenter = data.isPresenter
    if Conf.user.isPresenter 
      do Conf.user.stream.open
      do Conf.user.transcript.capture

  socket.on "transcript-update", (data) ->
    console.log "fuck you billy"
    ($ "#transcript .target").html data.transcript

module.exports = bind : bind
