$ ->
  poll = ->
    $.ajax url: "/live_data.json", method: 'GET', dataType: 'json', success: got
  got = (data) ->
    $('#hashrate').text(data.hashrate)
    $('#blocks_found').text(data.blocks_found)
    $('#blocks_total').text(data.blocks_total)
    $('#difficulty').text(data.difficulty)
    setTimeout(poll, 10000)
  poll()
