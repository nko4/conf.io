###
conf.io
author: gordon hall

sockets.coffee - binds socket event listeners
###

gravatar = require "./gravatar"

module.exports = (io) ->
  rooms = io.sockets.manager.rooms
  
  io.sockets.on "connection", (socket) ->
    id   = socket.id
    room = null
    # user role is unknown - if they are the first to
    # join, then they are the presenter else a participant
    socket.on "requested-join", (data) ->
      console.log data.room
      # room exists, join as participant
      console.log rooms, rooms[data.room]
      isPresenter = !rooms["/#{data.room}"]
      # join the room (or create it)
      socket.join data.room
      room = data.room
      # tell the client we have joined and what our role is
      eventData = 
        isPresenter: isPresenter
        topic: data.topic
        username: data.username
        uuid: data.uuid
        gravatar: gravatar data.email or ""
        socket: socket.id

      socket.emit "joined-conference", eventData
      (socket.broadcast.to data.room).emit "participant-joined", eventData

    socket.on "transcript-update", (data) ->
      (socket.broadcast.to data.room).emit "transcript-update", data

    socket.on "disconnect", ->
      (socket.broadcast.to room).emit "participant-left", 
        socket: socket.id
