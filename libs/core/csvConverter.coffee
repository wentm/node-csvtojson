
#implementation
#see http://www.adaltas.com/projects/node-csv/from.html

#it is a bridge from csv component to our parsers
csvAdv = (constructResult) ->
  constructResult = true  if constructResult isnt false
  instance = csv.apply(this)
  @parseRules = []
  @resultObject = csvRows: []
  @headRow = []
  that = this
  instance.on "record", (row, index) ->
    if index is 0
      that._headRowProcess row
    else
      resultRow = {}
      that._rowProcess row, index, resultRow
      that.resultObject.csvRows.push resultRow  if constructResult
      instance.emit "record_parsed", resultRow, row, index

  instance.on "end", ->
    instance.emit "end_parsed", that.resultObject, that.resultObject.csvRows

  instance
module.exports = csvAdv
csv = require("csv")
parserMgr = require("./parserMgr.js")
utils = require("util")
csvAdv::_headRowProcess = (headRow) ->
  @headRow = headRow
  @parseRules = parserMgr.initParsers(headRow)

csvAdv::_rowProcess = (row, index, resultRow) ->
  i = 0

  while i < @parseRules.length
    item = row[i]
    parser = @parseRules[i]
    head = @headRow[i]
    parser.parse
      head: head
      item: item
      itemIndex: i
      rawRow: row
      resultRow: resultRow
      rowIndex: index
      resultObject: @resultObject

    i++
