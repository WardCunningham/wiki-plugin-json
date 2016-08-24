
expand = (text)->
  text
    .replace /&/g, '&amp;'
    .replace /</g, '&lt;'
    .replace />/g, '&gt;'
    .replace /\*(.+?)\*/g, '<i>$1</i>'

ago = (msec) ->
  min = Math.round msec / 60000
  "#{min} minutes"

stats = (item) ->
  "#{JSON.stringify(item.resource).length} bytes
  written #{ago(Date.now() - item.written)} ago
  after #{ago(item.interval)}."

emit = ($item, item) ->
  $item.append """
    <div style="background-color:#eee;padding:16px;">
      <p>#{expand(item.text)}</p>
      <p class="caption">#{stats(item)}<p>
    </div>
  """

bind = ($item, item) ->
  $item.dblclick -> wiki.textEditor $item, item

window.plugins.json = {emit, bind} if window?
module.exports = {expand} if module?

