###
conf.io
author: gordon hall

server.coffee - starts application server
###

nko              = require "nko", "MgCWyiZUBOtGD97E"
fs               = require "fs"
http             = require "http"
express          = require "express"
io               = require "socket.io"
coffeescript     = require "coffee-middleware"
sockets          = require "./sockets"
bindRoutes       = require "./routes"
app              = express()
server           = http.createServer app
isProduction     = process.env.NODE_ENV is "production"
port             = if isProduction then 80 else 8000

# attach router to app instance
bindRoutes app
# configure server
app.configure ->
  app.set "views", __dirname + "/../views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use coffeescript
    src: __dirname + "/client"
    dest: __dirname + "/../public/lib"
    force: not isProduction
  app.use express.static __dirname + "/../public"
# start server
app.listen port, (err) ->
  if err
    console.log err
    process.exit -1
  # if run as root, downgrade to the owner of this file
  if process.getUid is 0
    fs.stat __filsname, (err, stats) ->
      if err then return console.error err
      process.setuid stats.uid
  console.log "Conf.io server running on port #{port}"
# initialize socket.io
io.listen server
# bind socket listeners
sockets io
