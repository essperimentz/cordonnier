express     = require 'express'
path        = require 'path'
fs          = require 'fs'
querystring = require 'querystring'
server      = express.createServer()
server.configure ()->
    server.use express.methodOverride()
    server.use express.bodyParser()
    server.use server.router

server.configure 'development', ()->
    server.use express.static path.resolve path.join __dirname ,'..', '/public'
    server.use express.errorHandler dumpExceptions: true, showStack: true
    
server.configure 'production', ()->
    oneYear = 31557600000
    server.use express.static path.resolve( path.join( __dirname ,'..', '/public' ) ), maxAge: oneYear
    server.use express.errorHandler()

server.listen(8000)