makeFakeText = (len, count) ->
  len = len || 21
  count = +count
  needCapitalize = true
  capitalize = (char) ->
    if needCapitalize
      needCapitalize = false
      char.toUpperCase()
    else
      char
  text = ""
  possibleOne = "aeiou"
  possibleTwo = "bcdfghjklmnpqrstvwxyz"
  while text.length + 5 < len
    if text and Math.round(Math.random() * 2)
      text += " "
      needCapitalize = true
    if Math.round(Math.random() * 2)
      text += capitalize possibleOne.charAt(Math.floor(Math.random() * possibleOne.length))
    text += capitalize possibleTwo.charAt(Math.floor(Math.random() * possibleTwo.length))
    text += possibleOne.charAt(Math.floor(Math.random() * possibleOne.length))
    if Math.round(Math.random() * 2)
      text += possibleTwo.charAt(Math.floor(Math.random() * possibleTwo.length))
    count-- # -1 if count undefined
    if count is 0
      break
  text

getValues = (options, type) ->
  # TODO: support allowedValues
  if typeof options is "function"
    options = options.call()
  # Hashtable
  if _.isObject(options) and not _.isArray(options)
    _.map options, (v, k) ->
      type(k)
  else
    _.map options, (o) ->
      o.value

fillValues = (values, count) ->
  count = Math.round(Math.random() * count) || 1
  result = []
  i = count
  while i--
    result.push(values[Math.floor(Math.random() * values.length)])
  _.uniq(result)

getFakeText = (fieldName, maxLength) ->
  if maxLength
    makeFakeText(maxLength, Math.round(maxLength / 10))
  else
    makeFakeText()

joinPathComponents = (a, b) ->
  if a and a.length > 0
    return a + "." + b
  else
    return b

getSubkeys = (baseString, remainingComponents) ->
  if remainingComponents.length == 0
    return [baseString]
  if remainingComponents[0] == "$"
    return _.chain(_.range(result[baseString].length))
      .map((v, idx)->
        return getSubkeys(
          joinPathComponents(baseString, idx),
          remainingComponents.slice(1))
      )
      .flatten()
      .value()
  else
    return getSubkeys(
      joinPathComponents(baseString, remainingComponents[0]),
      remainingComponents.slice(1))

AutoForm.Fixtures = {}

AutoForm.Fixtures.getPreData = (ss, getFakeTextCallback) ->
  getFakeTextCallback = getFakeTextCallback || getFakeText
  result = {}
  schema = ss.schema()
  for schemaK of schema
    field = schema[schemaK]
    if field.autoform?.omit
      continue
    for k in getSubkeys("", schemaK.split('.'))
      arrayField = null
      if schemaK.slice(-2) == ".$"
        arrayField = schema[schemaK.slice(0, -2)]
      if field.type.name is "Object"
        result[k] = {}
        continue
      if field.type.name is "Array"
        count = field.maxCount || 3
        result[k] = _.range(count)
        continue
      options = field.autoform?.options or
        field.autoform?.afFieldInput?.options or
        arrayField?.autoform?.options or
        arrayField?.autoform?.afFieldInput?.options
      if options
        values = getValues(options, field.type)
        result[k] = values[Math.floor(Math.random() * values.length)]
        continue
      if field.type.name is "String"
        if field.max
          max = field.max
          max = max.call() if typeof max is "function"
          result[k] = getFakeTextCallback(k, max)
        else
          result[k] = getFakeTextCallback(k)
        continue
      if field.type.name is "Number"
        min = 0
        if field.min
          min = field.min
          min = min.call() if typeof min is "function"
        max = 9
        if field.max
          max = field.max
          max = max.call() if typeof max is "function"
        range = [min..max]
        result[k] = range[Math.floor(Math.random() * range.length)]
        continue
      if field.type.name is "Date"
        min = false
        if field.min
          min = field.min
          min = min.call() if typeof min is "function"
        max = false
        if field.max
          max = field.max
          max = max.call() if typeof max is "function"
        if min and max
          days = moment(max).diff(moment(min), 'days')
          result[k] = moment(min).add(Math.round(Math.random() * days), 'day').toDate()
        else if min
          result[k] = moment(min).add(Math.round(Math.random() * 15000), 'day').toDate()
        else if max
          result[k] = moment(max).add(-Math.round(Math.random() * 15000), 'day').toDate()
        else
          result[k] = new Date()
        continue
      if field.type.name is "Boolean"
        result[k] = !!Math.round(Math.random())
        continue
  result

AutoForm.Fixtures.normalizeData = (data) ->
  result = {}
  for k of data
    namespace = k.split(".")
    resultObjPointer = result
    for pathComponent in namespace.slice(0,-1)
      resultObjPointer = resultObjPointer[pathComponent]
    resultObjPointer[namespace.slice(-1)[0]] = data[k]
  result

AutoForm.Fixtures.getData = (ss, getFakeTextCallback) ->
  data = AutoForm.Fixtures.getPreData(ss, getFakeTextCallback)
  AutoForm.Fixtures.normalizeData(data)
