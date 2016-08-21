fs = require 'fs'
path = require 'path'


asSlug = (name) ->
  name.replace(/\s/g, '-').replace(/[^A-Za-z0-9-]/g, '').toLowerCase()

escape = (text)->
  text
    .replace /&/g, '&amp;'
    .replace /</g, '&lt;'
    .replace />/g, '&gt;'

expandLinks = (origin, string) ->
  stashed = []

  stash = (text) ->
    here = stashed.length
    stashed.push text
    "〖#{here}〗"

  unstash = (match, digits) ->
    stashed[+digits]

  internal = (match, name) ->
    slug = asSlug name
    stash """<a href="#{origin}/#{slug}.html">#{escape name}</a>"""

  external = (match, href, protocol, rest) ->
    stash """<a href="#{href}" #{escape rest} </a>"""

  string = string
    .replace /〖(\d+)〗/g, "〖 $1 〗"
    .replace /\[\[([^\]]+)\]\]/gi, internal
    .replace /\[((http|https|ftp):.*?) (.*?)\]/gi, external
  escape string
    .replace /〖(\d+)〗/g, unstash

ignoreLinks = (string) ->
  internal = (match, name) ->
    name

  external = (match, href, protocol, rest) ->
    rest

  string = string
    .replace /\[\[([^\]]+)\]\]/gi, internal
    .replace /\[((http|https|ftp):.*?) (.*?)\]/gi, external
  escape string

publishing = (sitemap, story, index) ->
  map = {}
  map[s.slug] = s for s in sitemap
  selected = []
  for item in story[(index+1)..]
    if item.text && (m = item.text.match /\[\[(.*?)\]\]/)
      if siteref = map[link = asSlug(m[1])]
        selected.push {item, link, siteref}
  selected

startServer = (params) ->
  app = params.app
  console.log 'startServer json'

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
      item = page.story[plugin]
      console.log req.body
      item.resource = req.body
      app.pagehandler.put slug, page, (err) ->
        return res.e err if err
        res.json {status: 'ok', length:JSON.stringify(item, null, '  ').length}

module.exports = {startServer}
