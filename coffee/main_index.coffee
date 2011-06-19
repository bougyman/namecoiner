$ ->
  poll = ->
    $.ajax url: "/live_data.json", method: 'GET', dataType: 'json', success: got
  got = (data) ->
    $('#hashrate').text(data.hashrate)
    $('#blocks_found').text(data.blocks_found)
    $('#blocks_total').text(data.blocks_total)
    $('#difficulty').text(data.difficulty)
    $('#current_share_count').text(data.current_share_count)
    setTimeout(poll, 15000)
  poll()
