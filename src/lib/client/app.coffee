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

  # adjust ui proportions
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
  # forse adjustment on load
  ($ window).trigger "resize"

  # toolbar bindings
  transcriptTarget = ($ "#transcript .container .target")
  fontInc          = ($ ".tools button.font-inc")
  fontDec          = ($ ".tools button.font-dec")
  print            = ($ ".tools button.print")

  fontInc.bind "click", ->
    currentFontSize = transcriptTarget.css "font-size"
    transcriptTarget.css "font-size", "#{(parseInt currentFontSize) + 1}px"
  fontDec.bind "click", ->
    currentFontSize = transcriptTarget.css "font-size"
    transcriptTarget.css "font-size", "#{(parseInt currentFontSize) - 1}px"
  print.bind "click", -> do window.print

  Conf.room = (location.pathname.split "/")[2]
  socket.emit "requested-join", 
    uuid: currentUser
    room: Conf.room

