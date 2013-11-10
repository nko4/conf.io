###
conf.io
author: gordon hall

sockets.coffee - binds socket event listeners
###

gravatar = require "./gravatar"

module.exports = (io) ->
  rooms        = io.sockets.manager.rooms
  participants = {}
  topics       = {}
  
  io.sockets.on "connection", (socket) ->
    id           = socket.id
    room         = null

    socket.on "joined-room", (data) ->
      room = data.room
      if room then socket.emit "got-topic", topic: topics[room]

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

      if eventData.isPresenter then topics[room] = data.topic
      # send conf topic over
      if topics[data.room]
        socket.emit "got-topic", 
          topic: topics[data.room]

      if not participants[data.room] then participants[data.room] = {}
      participants[data.room][socket.id] = eventData

      console.log participants[socket.id]

      socket.emit "joined-conference", 
        event: participants[room][socket.id]
        participants: participants[room]
        topic: topics[data.room]

      (socket.broadcast.to data.room).emit "participant-joined", 
        event: participants[room][socket.id]
        participants: participants[room]

    socket.on "transcript-update", (data) ->
      (socket.broadcast.to data.room).emit "transcript-update", data      

    socket.on "disconnect", ->
      console.log room
      if room 
        delete participants[room]?[socket.id]
        (socket.broadcast.to room).emit "participant-left", 
          socket: socket.id
