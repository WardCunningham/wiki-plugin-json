# JSON plugin, server-side component
# These handlers are launched with the wiki server. They provide restful endpoints
# to the 'resource' attribute of the instantiated plugin's own item json.

startServer = (params) ->
  app = params.app

  app.get '/plugin/json/:slug', (req, res) ->
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
      key = "35ece947aa90b581"
      return res.status(401).json({status: 'error', error: "Invalid x-api-key in header"}) unless req.headers['x-api-key'] == key
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
      item.written = Date.now()
      app.pagehandler.put slug, page, (err) ->
        return res.e err if err
        res.json
          status: 'ok'
          writes: item.writes
          interval: item.interval
          length: JSON.stringify(item.resource).length

module.exports = {startServer}
