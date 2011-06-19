(function() {
  $(function() {
    var got, poll;
    poll = function() {
      return $.ajax({
        url: "/live_data.json",
        method: 'GET',
        dataType: 'json',
        success: got
      });
    };
    got = function(data) {
      $('#hashrate').text(data.hashrate);
      $('#blocks_found').text(data.blocks_found);
      $('#blocks_total').text(data.blocks_total);
      $('#difficulty').text(data.difficulty);
      $('#current_share_count').text(data.current_share_count);
      return setTimeout(poll, 15000);
    };
    return poll();
  });
}).call(this);
