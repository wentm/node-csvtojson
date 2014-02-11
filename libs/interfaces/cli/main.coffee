###
Convert input to process stdout
###

#module interfaces

#implementation
convertFile = (fileName) ->
  csvConverter = _initConverter()
  csvConverter.from fileName
convertString = (csvString) ->
  csvConverter = _initConverter()
  csvConverter.from csvString
_initConverter = ->
  csvConverter = new Converter()
  started = false
  writeStream = process.stdout
  csvConverter.on "record_parsed", (rowJSON) ->
    writeStream.write ",\n"  if started
    writeStream.write JSON.stringify(rowJSON) #write parsed JSON object one by one.
    started = true  if started is false

  writeStream.write "[\n" #write array symbol
  csvConverter.on "end_parsed", ->
    writeStream.write "\n]" #end array symbol

  csvConverter.on "error", (err) ->
    console.error err
    process.exit -1

  csvConverter
module.exports.convertFile = convertFile
module.exports.convertString = convertString
Converter = require("../../core").Converter
