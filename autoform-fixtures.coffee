makeFakeText = (len, count) ->
  len = len || 21
  count = +count
  text = ""
  possibleOne = "aeiou"
  possibleTwo = "bcdfghjklmnpqrstvwxyz"
  while text.length + 4 < len
    if Math.round(Math.random() * 2)
      text += possibleOne.charAt(Math.floor(Math.random() * possibleOne.length))
    text += possibleTwo.charAt(Math.floor(Math.random() * possibleTwo.length))
    text += possibleOne.charAt(Math.floor(Math.random() * possibleOne.length))
    if Math.round(Math.random() * 2)
      text += possibleTwo.charAt(Math.floor(Math.random() * possibleTwo.length))
    count--
    if count is 0
      break
    if text.length + 5 < len and Math.round(Math.random() * 2)
      text += " "
  text

getValues = (field, type) ->
  options = field.autoform.options
  if typeof options is "function"
    options = options.call()
  # Hashtable
  if _.isObject(options) and not _.isArray(options)
    return _.map options, (v, k) ->
      type(k)
  # TODO: support allowedValues
  _.map options, (o) ->
    o.value

fillValues = (values, count) ->
  result = []
  i = 0
  while i < count
    result.push(values[Math.floor(Math.random() * values.length)])
    i++
  _.uniq(result)

getFakeText = (fieldName, maxLength) ->
  if maxLength
    return makeFakeText(maxLength, Math.round(maxLength / 10))
  makeFakeText()

AutoForm.Fixtures = {}

AutoForm.Fixtures.getPreData = (ss, getFakeTextCallback) ->
  getFakeTextCallback = getFakeTextCallback || getFakeText
  result = {}
  schema = ss.schema()
  for k of schema
    field = schema[k]
    if field.autoform?.omit or k.slice(-2) is ".$"
      continue
    if field.type.name is "Object"
      result[k] = {}
      continue
    if field.type.name is "Array"
      element = ss.schema(k + ".$")
      if ["String", "Number"].indexOf(element.type.name) + 1
        if field.autoform?.options
          values = getValues(field, element.type)
          count = field.maxCount || values.length
          result[k] = fillValues(values, count)
        else
          throw new Error(k + " - ss without options")
      else
        throw new Error(k + " - not supported type [" + element.type.name + "]")
      continue
    if field.autoform?.options
      values = getValues(field, field.type)
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

AutoForm.Fixtures.normalizeData = (result) ->
  normalData = {}
  for k of result
    namespace = k.split(".")
    # stupid code, sorry
    if namespace.length is 1
      normalData[namespace[0]] = result[k]
    else if namespace.length is 2
      normalData[namespace[0]][namespace[1]] = result[k]
    else if namespace.length is 3
      normalData[namespace[0]][namespace[1]][namespace[2]] = result[k]
    else
      throw new Error("Current version is support only 3 level of namespace")
  normalData

AutoForm.Fixtures.getData = (ss, getFakeTextCallback) ->
  result = AutoForm.Fixtures.getPreData(ss, getFakeTextCallback)
  AutoForm.Fixtures.normalizeData(result)
