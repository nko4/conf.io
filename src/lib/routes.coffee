###
conf.io
author: gordon hall

routes.coffee - binds application routes
###

isProduction = process.env.NODE_ENV is "production"
browserify   = require "browserify"
coffeeify    = require "coffeeify"
bundle       = null
topics       = (require "./sockets").topics
participants = (require "./sockets").participants

module.exports = (server) ->

  # render landing page
  server.get "/", (req, res) ->
    parsedTopics = []
    for room, topic of topics
      roomTopic = ""
      members   = 0
      for key, val of topics[room]
        roomTopic = val.topic
        members++

      if room
        parsedTopics.push 
          topic: roomTopic
          members: members
          id: room

    console.log parsedTopics
    data = 
      isProduction: isProduction
      topics: parsedTopics
    res.render "landing-page", data

  # render application ui
  server.get "/conferences/:conference_id", (req, res) ->
    data =
      isProduction: isProduction
      conferenceId: req.params.conference_id
    res.render "app", data

  # serve client application
  server.get "/lib/app.js", (req, res) ->
      unless isProduction and bundle
        console.log "Recompiling client bundle..."
        bundle = browserify "#{__dirname}/client/index.js"
        bundle.transform coffeeify
        bundle.bundle (err, file) ->
          bundle = if file then do file.toString else null
          console.log err or "Bundle compiled!"
          res.send err or bundle
      else
        console.log "Sent cached client bundle."
        res.send bundle
