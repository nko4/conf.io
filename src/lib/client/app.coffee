###
conf.io
author: gordon hall

app.coffee - application init
###

{UUID}      = require "./helpers.coffee"
events      = require "./events.coffee"
currentUser = localStorage.getItem "user-uuid"

# instantiate ember application
module.exports = window.Conf = Conf = {}

# create a new uuid for user if it doesn't already exist
unless currentUser
	localStorage.setItem "user-uuid", do (new UUID().toString)

# instantiate socket connection
socket = io.connect location.origin
events.bind socket
socket.emit "joined-conference", user: currentUser
