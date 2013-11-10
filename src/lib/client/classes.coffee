###
conf.io
author: gordon hall

helpers.coffee - helpers classes
###

class UUID
  spec: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  pattern: /[xy]/g
  constructor: ->
    @value = @spec.replace @pattern, (c) ->
      r = (do Math.random) * (16 | 0)
      v = if c is 'x' then r else (r & 0x3 | 0x8)
      v.toString 16
  toString: -> @value

class Transcript
  transcript: ""
  constructor: ->
    @recognition                = new webkitSpeechRecognition()
    @recognition.continuous     = true
    @recognition.interimResults = true
    @recognition.onstart        = @speechOn
    @recognition.onresult       = (event) => @transcribe event
    @recognition.onerror        = @handleTranscriptionError
    @recognition.onend          = @speechOff
  capture: ->
    @transcript = ""
    @recognition.lang = "en-US"
    do @recognition.start
    ($ ".speech-toggle").show()
  speechOn: ->
    console.log "speech capture on"
    ($ ".speech-toggle").removeClass "off"
    ($ ".speech-toggle").addClass "on"
  speechOff: ->
    console.log "speech capture off"
    ($ ".speech-toggle").removeClass "on"
    ($ ".speech-toggle").addClass "off"
  transcribe: (event) ->
    # show indicator
    clearTimeout Conf.user.isSpeaking
    ($ ".speech-toggle").addClass "speaking"
    Conf.user.isSpeaking = setTimeout -> ($ ".speech-toggle").removeClass "speaking", 1000

    interimTranscript = ""
    currentIndex      = event.resultIndex
    results           = Array::slice.call event.results, currentIndex

    for result in results
      if result.isFinal
        @transcript += result[0]?.transcript + "..."
      else
        interimTranscript += result[0]?.transcript

    interimTranscript = @capitalize interimTranscript
    @transcript       = "#{@capitalize @transcript}"
    @state            = "#{@transcript}<em>#{interimTranscript}</em>"
    ($ window).trigger "resize"
    # inform clients of transcription
    do @emit

    ($ "#transcript .target").html @state
  handleTranscriptionError: (error) =>
    console.log "speech capture error:", error
  emit: ->
    # emit the transcribe event to everyone else in the conference
    if Conf.user?.isPresenter then Conf.user.socket.emit "transcript-update", 
      transcript: @state
      room: Conf.room
      language: ($ "#transcript .language").val()
  insertQuestion: (username, question) ->
    questionElement = "<span class=\"question\">#{username}: #{question}</span>"
    @transcript    += "\n\n#{questionElement}"
    @state          = "#{@state}#{questionElement}" 
    do @emit
    ($ "#transcript .target").html @state
  translate: (text, language_from=en, language_to=en) ->
    data =
        format: "html"
        key: "AIzaSyD8s32cxuRLMljFmopvI0pr4OvoPGEiYRM"
        prettyprint: yes
        source: language_from
        target: language_to
        q: text

    $.getJSON "https://www.googleapis.com/language/translate/v2", data, (response) ->
      translation = response.data.translations[0].translatedText
      console.log translation, data
      ($ "#transcript .target").html translation

  capitalize: (string) =>
    capital= do (string.charAt 0).toUpperCase
    capital + string.substr 1
  linebreak: (string) => 
    string.replace "\n", "<br />"

class AVStream
  constructor: ->
    @connection        = new RTCMultiConnection()
    @connection.userid = localStorage.getItem "user-uuid"
    # audio / video / data / screen / oneway / broadcast
    @connection.session =
      audio: yes
      video: yes
      broadcast: yes
    @connection.direction     = "one-way"
    @connection.onstream      = @connect
    @connection.onstreamended = @disconnect
    do @connection.connect
    console.log @connection
  connect: (stream) =>
    console.log "Got stream:", stream.streamid
    console.log stream.type
    if stream.type is "local"
      if Conf.user?.isPresenter
        ($ "#video .presenter").attr "src", stream.blobURL
        ($ "#video .presenter").prop "muted", true
    if stream.type is "remote" and !Conf.user.isPresenter
      unless @remoteStreamActive
        ($ "#video .presenter").attr "src", stream.mediaElement.src
        @remoteStreamActive = yes
  disconnect: (stream) =>
    videoElement   = stream.mediaElement
    videoContainer = stream.mediaElement.parentNode
    if videoContainer then videoContainer.removeChild videoElement
  open: -> 
    do @connection.open if Conf.user.isPresenter
  remoteStreamActive: no

class User
  constructor: (opts) ->
    @uuid       = opts.userId
    @socket     = opts.socket
    @stream     = opts.stream
    @transcript = opts.transcript
  askQuestion: (question_text) ->
    # add question to transcript for all users
  raiseHand: (question) ->
    console.log "requesting floor", @socket
    @socket.emit "floor-requested", 
      id: @socket.socket.sessionid,
      question: question

# expose classes
module.exports =
  UUID: UUID
  Transcript: Transcript
  AVStream: AVStream
  User: User
