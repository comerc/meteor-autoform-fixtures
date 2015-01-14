# comerc:autoform-fixtures
Get fixtures data from [SimpleSchema](https://github.com/aldeed/meteor-simple-schema) with [AutoForm](https://github.com/aldeed/meteor-autoform). 

 

Usage
-----
It is creating random/fake data automatically based on the collection schema.
```coffee
ss = Collections.MyCollection.simpleSchema()
data = AutoForm.Fixtures.getData(ss)
Collections.MyCollection.insert(data)
```
You may use `autoform.omit` for exclude fields:
```coffee
MyCollection.attachSchema new SimpleSchema
  userId:
    type: String
    autoform:
      omit: true
    autoValue: ->
      Meteor.userId()
```
You may use [anti:fake](https://github.com/anticoders/meteor-fake/) with `getFakeTextCallback`
```coffee
getFakeText = (fieldName, maxLength) ->
  if fieldName is "my.name"
    Fake.word()
  else if maxLength
    Fake.sentence(Math.round(maxLength / 10))
  else
    Fake.paragraph()
  
data = AutoForm.Fixtures.getData(ss, getFakeText)
```
You may use intermediate operations with namespace in mongo-style
```coffee
data = AutoForm.Fixtures.getPreData(ss)
data["my"] = {} 
data["my.name"] = "foo"
data = AutoForm.Fixtures.normalizeData(data)
# {my: name: "foo"}
```
