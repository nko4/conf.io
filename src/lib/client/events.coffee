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
      username: data.username

    # open stream to other is presenter
    Conf.user.isPresenter = data.isPresenter
    if Conf.user.isPresenter 
      do Conf.user.stream.open
      do Conf.user.transcript.capture

    console.log "joined: (presenter)", data
    template = Handlebars.compile ($ "[data-template-name='participant-list']").html()
    ($ "#participants .presenter").html template data

  socket.on "participant-joined", (data) ->
    console.log "joined: (participant)", data
    template = Handlebars.compile ($ "[data-template-name='participant-list']").html()
    ($ "#participants .participants").append template data

  socket.on "transcript-update", (data) ->
    myLanguage = ($ "#transcript .language").val()
    theirLanguage = data.language

    if theirLanguage isnt myLanguage
      # translate incoming text
      classes.Transcript::translate data.transcript, theirLanguage, myLanguage
    else 
      ($ "#transcript .target").html data.transcript

  socket.on "participant-left", (data) ->
    console.log "LEFT:", data
    ($ "#participants [data-id=#{data.socket}]").remove()

module.exports = bind : bind
