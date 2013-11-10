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
    Conf.user.isPresenter = data.event.isPresenter
    if Conf.user.isPresenter 
      do Conf.user.stream.open
      do Conf.user.transcript.capture

    console.log "joined: (presenter)", data
    template = Handlebars.compile ($ "[data-template-name='participant-list']").html()
    ($ "#participants .presenter").html template data.event
    console.log "PARTICIPANTS!!", data.participants
    for id, participant of data.participants
      console.log "getting participants (i joined)", participant
      if not ($ "[data-id='#{id}']").length
        ($ "#participants .participants").append template participant

  socket.on "participant-joined", (data) ->
    console.log "joined: (participant)", data.event
    template = Handlebars.compile ($ "[data-template-name='participant-list']").html()
    ($ "#participants .participants").append template data.event
    for id, participant of data.participants
      console.log "getting participants (they joined)", participant
      if not ($ "[data-id='#{id}']").length
        ($ "#participants .participants").append template participant

  socket.on "transcript-update", (data) ->
    myLanguage = ($ "#transcript .language").val()
    theirLanguage = data.language
    console.log data.transcript
    if theirLanguage isnt myLanguage
      # translate incoming text
      classes.Transcript::translate data.transcript, theirLanguage, myLanguage
    else 
      ($ "#transcript .target").html data.transcript
    ($ window).trigger "resize"
    
  socket.on "participant-left", (data) ->
    console.log "LEFT:", data
    ($ "#participants [data-id=#{data?.socket}]").remove()

  socket.on "got-topic", (data) ->
    topic = data.topic
    if topic
      ($ "#transcript .conference-title").html topic
      ($ "#topic").val(topic).attr "disabled", "disabled"

  socket.on "hand-raise", (data) ->
    id  = data.id
    src = data.src
    console.log "hand raised!", data
    ($ "[data-id='#{id}']").addClass "handRaised"
    ($ "[data-id='#{id}']").data "videoSrc", src

  socket.on "floor-received", (data) ->
    console.log "floor is being given to #{data.id}"
    ($ "[data-id='#{data.id}']").removeClass "handRaised"
    if Conf.user?.socket.socket.sessionid is data.id
      # here, show user a prompt to type a question
      # then listen for finished event and emit to all users
      # the question bubble
      console.log "thing"



module.exports = bind : bind
