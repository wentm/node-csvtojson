#module interfaces

#implementation
registerParser = (parser) ->
  registeredParsers.push parser  if registeredParsers.indexOf(parser) is -1  if parser instanceof Parser
addParser = (name, regExp, parseFunc) ->
  parser = new Parser(name, regExp, parseFunc)
  registerParser parser
initDefaultParsers = ->
  i = 0

  while i < defaultParsers.length
    parserCfg = defaultParsers[i]
    addParser parserCfg.name, parserCfg.regExp, parserCfg.parserFunc
    i++
initParsers = (row) ->
  parsers = []
  i = 0

  while i < row.length
    columnTitle = row[i]
    parsers.push getParser(columnTitle)
    i++
  parsers
getParser = (columnTitle) ->
  i = 0

  while i < registeredParsers.length
    parser = registeredParsers[i]
    return parser  if parser.test(columnTitle)
    i++
  new Parser()

#default parsers
_arrayParser = (params) ->
  fieldName = params.head.replace(@regExp, "")
  params.resultRow[fieldName] = []  if params.resultRow[fieldName] is `undefined`
  params.resultRow[fieldName].push params.item
_jsonParser = (params) ->
  fieldStr = params.head.replace(@regExp, "")
  headArr = fieldStr.split(".")
  pointer = params.resultRow
  while headArr.length > 1
    headStr = headArr.shift()
    pointer[headStr] = {}  if pointer[headStr] is `undefined`
    pointer = pointer[headStr]
  pointer[headArr.shift()] = params.item
_jsonArrParser = (params) ->
  fieldStr = params.head.replace(@regExp, "")
  headArr = fieldStr.split(".")
  pointer = params.resultRow
  while headArr.length > 1
    headStr = headArr.shift()
    pointer[headStr] = {}  if pointer[headStr] is `undefined`
    pointer = pointer[headStr]
  arrFieldName = headArr.shift()
  pointer[arrFieldName] = []  if pointer[arrFieldName] is `undefined`
  pointer[arrFieldName].push params.item
module.exports.addParser = addParser
module.exports.initParsers = initParsers
module.exports.getParser = getParser
registeredParsers = []
Parser = require("./parser.js")
defaultParsers = [
  {
    name: "array"
    regExp: /^\*array\*/
    parserFunc: _arrayParser
  }
  {
    name: "json"
    regExp: /^\*json\*/
    parserFunc: _jsonParser
  }
  {
    name: "omit"
    regExp: /^\*omit\*/
    parserFunc: ->
  }
  {
    name: "jsonarray"
    regExp: /^\*jsonarray\*/
    parserFunc: _jsonArrParser
  }
]
initDefaultParsers()
