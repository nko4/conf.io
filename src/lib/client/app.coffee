###
conf.io
author: gordon hall

app.coffee - application init
###

classes     = require "./classes.coffee"
events      = require "./events.coffee"
currentUser = localStorage.getItem "user-uuid"

# instantiate ember application
module.exports = window.Conf = Conf = {}

# create a new uuid for user if it doesn't already exist
unless currentUser
  localStorage.setItem "user-uuid", do (new classes.UUID().toString)

# instantiate socket connection
socket = io.connect location.origin
events.bind socket

# kick off stuff
($ document).ready ->

  # adjust ui
  ($ window).resize (event) ->
    header       = ($ "header").height()
    participants = ($ "#participants").width()
    winHeight    = ($ window).height()
    winWidth     = ($ window).width()
    transcript   = ($ "#transcript").height()
    transTools   = ($ "#transcript .tools").height()

    ($ "#speakers").css
      height: "#{winHeight - header}px"
      width: "#{winWidth - participants}px"
      top: "#{header}px"
    ($ "#transcript .container").css
      height: "#{transcript - transTools}px"

  ($ window).trigger "resize"

  Conf.room = (location.pathname.split "/")[2]
  socket.emit "requested-join", 
    uuid: currentUser
    room: Conf.room

