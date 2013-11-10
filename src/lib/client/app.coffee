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

# set room name
Conf.room = (location.pathname.split "/")[2]

# create a new uuid for user if it doesn't already exist
unless currentUser 
  currentUser = do (new classes.UUID().toString)
  localStorage.setItem "user-uuid", currentUser

# instantiate socket connection
socket = io.connect location.origin
events.bind socket

Conf.showJoinDialog = ->
  ($ "#main").addClass "grayscale"

  socket.emit "joined-room", room: Conf.room

  ($ "#join_dialog").show().unbind('submit').bind "submit", (e) ->
    do e.preventDefault
    ($ "#main").removeClass "grayscale"
    ($ "#join_dialog").hide()

    Conf.join  
      uuid: currentUser
      room: Conf.room
      username: ($ "#username").val() or "anonymous"
      topic: ($ "#topic").val() or "Not Specified"
      email: ($ "#email").val() or null

Conf.join = (data) -> socket.emit "requested-join", data

# kick off stuff
($ document).ready ->

  # check to makes sure we are using chrome
  chrome = /chrom(e|ium)/.test navigator.userAgent.toLowerCase()
  if not chrome
    ($ "#main").addClass "grayscale"
    ($ ".block-ui").show()

  ($ "body").bind "click", -> ($ "#ask").fadeOut "fast"
  # bind hand raise request
  ($ ".ask-question").bind "click", (e) -> 
    e.stopPropagation()
    ($ "#ask").fadeIn "fast"
  ($ ".send-question").bind "click", (e) -> e.stopPropagation()
  ($ ".send-question").bind "submit", (e) -> 
    e.preventDefault()
    console.log "sending question..."
    questionText = ($ "textarea", @).val()
    Conf.user?.raiseHand questionText
    ($ "textarea", @).val ""
    ($ @).parent().fadeOut "fast"

  ($ ".speech-toggle").bind "click", ->
    if Conf.user?.isPresenter
      if ($ @).hasClass "on" then do Conf.user?.transcript?.recognition.stop
      else if ($ @).hasClass "off" then do Conf.user?.transcript?.recognition.start

  # adjust ui proportions
  ($ window).resize (event) ->
    header       = ($ "header").height()
    participants = ($ "#participants").width()
    winHeight    = ($ window).height()
    winWidth     = ($ window).width()
    transcript   = ($ "#transcript").height()
    transTools   = ($ "#transcript .tools").height()

    # scroll to bottom of transcription
    ($ "#transcript .container").animate
      scrollTop: ($ "#transcript .container")[0].scrollHeight, 1000

    ($ "#speakers").css
      height: "#{winHeight - header}px"
      width: "#{winWidth - participants}px"
      top: "#{header}px"
    ($ "#transcript .container").css
      height: "#{transcript - transTools - 24}px"
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
  print.bind "click", -> 
    print_window = do window.open
    transcript   = ($ "#transcript .target").html()
    ($ print_window.document.body).html transcript
    ($ "body .question", print_window)
    do print_window.print

  if not Conf.user?.isPresenter then do Conf.showJoinDialog
