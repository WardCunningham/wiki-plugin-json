
expand = (text)->
  text
    .replace /&/g, '&amp;'
    .replace /</g, '&lt;'
    .replace />/g, '&gt;'
    .replace /\*(.+?)\*/g, '<i>$1</i>'

ago = (msecs) ->
  return "#{Math.floor msecs} milliseconds" if (secs = msecs/1000) < 2
  return "#{Math.floor secs} seconds" if (mins = secs/60) < 2
  return "#{Math.floor mins} minutes" if (hrs = mins/60) < 2
  return "#{Math.floor hrs} hours" if (days = hrs/24) < 2
  return "#{Math.floor days} days" if (weeks = days/7) < 2
  return "#{Math.floor weeks} weeks" if (months = days/31) < 2
  return "#{Math.floor months} months" if (years = days/365) < 2
  return "#{Math.floor years} years"

stats = (item) ->
  result = []
  result.push "#{JSON.stringify(item.resource).length} bytes" if item.resource
  result.push "updated #{ago(Date.now() - item.written)} ago" if item.written
  result.push "after #{ago(item.interval)}." if item.interval
  result.push "empty" unless result.length
  result.join ' '

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

