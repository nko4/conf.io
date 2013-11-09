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
	Conf.room = (location.pathname.split "/")[2]
	socket.emit "requested-join", 
		uuid: currentUser
		room: Conf.room

