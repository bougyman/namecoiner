(function() {
  var graph, graphFound, graphShares, graphStales;
  graph = function(div, urls, options) {
    var alreadyFetched, data, onDataReceived, url, _i, _len, _results;
    data = [];
    $.plot(div, data, options);
    alreadyFetched = {};
    onDataReceived = function(series) {
      var firstcoordinate;
      firstcoordinate = '(' + series.data[0][0] + ', ' + series.data[0][1] + ')';
      if (!alreadyFetched[series.label]) {
        alreadyFetched[series.label] = true;
        data.push(series);
      }
      return $.plot(div, data, options);
    };
    _results = [];
    for (_i = 0, _len = urls.length; _i < _len; _i++) {
      url = urls[_i];
      _results.push($.ajax({
        url: url,
        method: 'GET',
        dataType: 'json',
        success: onDataReceived
      }));
    }
    return _results;
  };
  graphShares = function() {
    var options, urls;
    options = {
      lines: {
        fill: true,
        show: true
      },
      xaxis: {
        mode: "time",
        ticksize: [1, "hour"]
      }
    };
    urls = ["/graph/last_24h.json?label=Stale&r=stale", "/graph/last_24h.json?label=Valid&o=true"];
    return graph($("#graph-shares"), urls, options);
  };
  graphStales = function() {
    var options, urls;
    options = {
      lines: {
        fill: true,
        show: true
      },
      xaxis: {
        mode: "time",
        ticksize: [1, "hour"]
      }
    };
    urls = ["/graph/last_24h.json?label=Stale&r=stale"];
    return graph($("#graph-stales"), urls, options);
  };
  graphFound = function() {
    var options, urls;
    options = {
      lines: {
        show: true
      },
      points: {
        show: true
      },
      xaxis: {
        mode: "time",
        tickSize: [1, "day"]
      },
      yaxis: {
        minTickSize: 1,
        tickSize: 1
      }
    };
    urls = ["/graph/last_7d.json?label=Found&u=true&o=true"];
    return graph($("#graph-found"), urls, options);
  };
  $(function() {
    graphShares();
    graphStales();
    return graphFound();
  });
}).call(this);
