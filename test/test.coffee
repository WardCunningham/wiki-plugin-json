# build time tests for json plugin
# see http://mochajs.org/

json = require '../client/json'
expect = require 'expect.js'

describe 'json plugin', ->

  describe 'expand', ->

    it 'can make itallic', ->
      result = json.expand 'hello *world*'
      expect(result).to.be 'hello <i>world</i>'

  describe 'ago', ->

    it 'can do short intervals', ->
      result = json.ago(3000)
      expect(result).to.be '3 seconds'
    it 'will round up', ->
      result = json.ago(24*3600*1000-12)
      expect(result).to.be '24 hours'
