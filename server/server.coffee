# JSON plugin, server-side component
# These handlers are launched with the wiki server. They provide restful endpoints
# to the 'resource' attribute of the instantiated plugin's own item json.

fs = require 'fs'
tokens = null

startServer = (params) ->
  app = params.app

  cors = (req, res, next) ->
    res.header("Access-Control-Allow-Origin", "*")
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    next()

  tokenFile = "#{params.argv.data}/status/plugin/json/tokens.json"
  fs.readFile tokenFile, (err, data) ->
    if err then return console.log "caution: #{err.message}"
    try tokens = JSON.parse data
    catch err then console.log "caution: #{tokenFile}: #{err.message}"

  app.get '/plugin/json/:slug', cors, (req, res) ->
    slug = req.params.slug
    app.pagehandler.get slug, (e, page, status) ->
      return res.e e if e
      plugin = page.story?.findIndex (item) ->
        item.type == 'json'
      return res.status(404).json({error: "No wiki-plugin-json on this page.", slug, resource}) unless plugin >= 0
      res.json page.story[plugin].resource

  app.put '/plugin/json/:slug', (req, res) ->
    slug = req.params.slug
    app.pagehandler.get slug, (e, page, status) ->
      return res.e e if e
      plugin = page.story?.findIndex (item) ->
         item.type == 'json'
      return res.status(404).json({status: 'error', error: "No wiki-plugin-json on this page.", slug}) unless plugin >= 0
      key = req.headers['x-api-key']
      auth = tokens?[slug]?[key] or tokens?['*']?[key]
      unless auth
        return res.status(401).json({status: 'error', error: "Missing or invalid x-api-key in header"})
      item = page.story[plugin]
      item.resource = req.body
      if item.slug && item.slug == slug && item.writes
        item.writes += 1
        if item.written
          item.interval = Date.now() - item.written
      else
        item.slug = slug
        item.writes = 1
        item.interval = undefined
      item.writer = auth.id
      item.written = Date.now()
      app.pagehandler.put slug, page, (err) ->
        return res.e err if err
        res.json
          status: 'ok'
          writes: item.writes
          interval: item.interval
          length: JSON.stringify(item.resource).length

module.exports = {startServer}
