# comerc:autoform-fixtures
Get fixtures data for [SimpleSchema](https://github.com/aldeed/meteor-simple-schema) with [AutoForm](https://github.com/aldeed/meteor-autoform). 

It is creating random/fake data automatically based on the collection schema. 

Usage
-----
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
    return Fake.word()
  if maxLength
    return Fake.sentence(Math.round(maxLength / 10))
  Fake.paragraph()
  
data = AutoForm.Fixtures.getData(ss, getFakeText)
```
