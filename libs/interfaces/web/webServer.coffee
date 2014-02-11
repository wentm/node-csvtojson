#module interfaces

#implementation
applyWebServer = (app, url) ->
  app.post url, _POSTData
startWebServer = (args) ->
  args = {}  if typeof args is "undefined"
  serverArgs = {}
  for key of defaultArgs
    if args[key]
      serverArgs[key] = args[key]
    else
      serverArgs[key] = defaultArgs[key]
  
  #expressApp.use(express.bodyParser());
  expressApp.post serverArgs.urlPath, _POSTData
  expressApp.get "/", (req, res) ->
    res.end "POST to " + serverArgs.urlPath + " with CSV data to get parsed."

  expressApp.listen serverArgs.port
  console.log "CSV Web Server Listen On:" + serverArgs.port
  console.log "POST to " + serverArgs.urlPath + " with CSV data to get parsed."
  expressApp
_POSTData = (req, res) ->
  csvString = ""
  req.setEncoding "utf8"
  req.on "data", (chunk) ->
    csvString += chunk

  req.on "end", ->
    _ParseString csvString, (err, JSONData) ->
      if err
        console.error err
      else
        res.json JSONData


_ParseString = (csvString, cb) ->
  converter = new CSVConverter()
  converter.on "end_parsed", (JSONData) ->
    cb null, JSONData

  converter.on "error", (err) ->
    cb err

  converter.from csvString
_ParseFile = (filePath, cb) ->
module.exports.startWebServer = startWebServer
module.exports.applyWebServer = applyWebServer
express = require("express")
expressApp = express()
CSVConverter = require("../../core").Converter
defaultArgs =
  port: "8801"
  urlPath: "/parseCSV"
