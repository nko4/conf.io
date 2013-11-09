###
conf.io
author: gordon hall

routes.coffee - binds application routes
###

isProduction = process.env.NODE_ENV is "production"

module.exports = (server) ->

  # render landing page
  server.get "/", (req, res) ->
    data = 
      isProduction: isProduction
    res.render "landing-page", data

  # render application
  server.get "/conferences/:conference_id", (req, res) ->
    data =
      isProduction: isProduction
      conferenceId: req.params.conference_id
    res.render "app", data
