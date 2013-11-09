###
conf.io
author: gordon hall

sockets.coffee - binds socket event listeners
###

module.exports = (io) ->
  rooms = io.sockets.manager.rooms
  
  io.sockets.on "connection", (socket) ->
    id = socket.id

    # user role is unknown - if they are the first to
    # join, then they are the presenter else a participant
    socket.on "requested-join", (data) ->
      console.log data.room
      # room exists, join as participant
      console.log rooms, rooms[data.room]
      isPresenter = !rooms["/#{data.room}"]
      # join the room (or create it)
      socket.join data.room
      # tell the client we have joined and what our role is
      socket.emit "joined-conference", 
        isPresenter: isPresenter

    socket.on "transcript-update", (data) ->
      (socket.broadcast.to data.room).emit "transcript-update", data
