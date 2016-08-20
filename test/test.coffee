# build time tests for json plugin
# see http://mochajs.org/

json = require '../client/json'
expect = require 'expect.js'

describe 'json plugin', ->

  describe 'expand', ->

    it 'can make itallic', ->
      result = json.expand 'hello *world*'
      expect(result).to.be 'hello <i>world</i>'
