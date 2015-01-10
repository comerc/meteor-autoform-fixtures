# comerc:autoform-fixtures
Get fixtures data for [Collection2](https://github.com/aldeed/meteor-collection2). It is creating random/fake data automatically based on the collection schema. 

Usage
-----
```coffee
data = AutoForm.Fixtures.getData(Collections.MyCollection.simpleSchema())
Collections.MyCollection.insert(data)
```
Note: you may use `autoform.omit` for exclude fields:
```coffee
myField:
  autoform:
    omit: true
```
