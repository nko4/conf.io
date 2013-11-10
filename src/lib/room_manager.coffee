###
conf.io
author: gordon hall

room_manager.coffee - tracks active conferences
###

hat   = require "hat"
rack  = do hat.rack 
rooms = {}

class Room
  constructor: (uuid, topic, members) ->
    @id        = do rack
    @topic     = topic 
    @members   = members.length
    rooms[uuid] = @

module.exports = 
  rooms: rooms
  Room: Room
  get: (id) -> rooms[id]
