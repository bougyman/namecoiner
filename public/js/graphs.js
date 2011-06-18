(function() {
  var graphFound, graphShares24h, graphShares60m;
  graphShares60m = function() {
    var alreadyFetched, data, graph, onDataReceived, options;
    options = {
      lines: {
        show: true
      },
      points: {
        show: true
      },
      xaxis: {
        mode: "time",
        ticksize: [1, "minute"]
      }
    };
    data = [];
    graph = $("#graph-shares-60m");
    $.plot(graph, data, options);
    alreadyFetched = {};
    onDataReceived = function(series) {
      var firstcoordinate;
      firstcoordinate = '(' + series.data[0][0] + ', ' + series.data[0][1] + ')';
      if (!alreadyFetched[series.label]) {
        alreadyFetched[series.label] = true;
        data.push(series);
      }
      return $.plot(graph, data, options);
    };
    $.ajax({
      url: "/graph/last_60m.json?label=Stale&r=stale",
      method: 'GET',
      dataType: 'json',
      success: onDataReceived
    });
    return $.ajax({
      url: "/graph/last_60m.json?label=Valid&o=true",
      method: 'GET',
      dataType: 'json',
      success: onDataReceived
    });
  };
  graphShares24h = function() {
    var alreadyFetched, data, graph, onDataReceived, options;
    options = {
      lines: {
        show: true
      },
      points: {
        show: true
      },
      xaxis: {
        mode: "time",
        ticksize: [1, "hour"]
      }
    };
    data = [];
    graph = $("#graph-shares");
    $.plot(graph, data, options);
    alreadyFetched = {};
    onDataReceived = function(series) {
      var firstcoordinate;
      firstcoordinate = '(' + series.data[0][0] + ', ' + series.data[0][1] + ')';
      if (!alreadyFetched[series.label]) {
        alreadyFetched[series.label] = true;
        data.push(series);
      }
      return $.plot(graph, data, options);
    };
    $.ajax({
      url: "/graph/last_24h.json?label=Stale&r=stale",
      method: 'GET',
      dataType: 'json',
      success: onDataReceived
    });
    return $.ajax({
      url: "/graph/last_24h.json?label=Valid&o=true",
      method: 'GET',
      dataType: 'json',
      success: onDataReceived
    });
  };
  graphFound = function() {
    var alreadyFetched, data, graph, onDataReceived, options;
    options = {
      lines: {
        show: true
      },
      points: {
        show: true
      },
      xaxis: {
        mode: "time",
        ticksize: [1, "hour"]
      },
      yaxis: {
        minTicksize: 1
      }
    };
    data = [];
    graph = $("#graph-found");
    $.plot(graph, data, options);
    alreadyFetched = {};
    onDataReceived = function(series) {
      var firstcoordinate;
      firstcoordinate = '(' + series.data[0][0] + ', ' + series.data[0][1] + ')';
      if (!alreadyFetched[series.label]) {
        alreadyFetched[series.label] = true;
        data.push(series);
      }
      return $.plot(graph, data, options);
    };
    return $.ajax({
      url: "/graph/last_24h.json?label=Found&u=true&o=true",
      method: 'GET',
      dataType: 'json',
      success: onDataReceived
    });
  };
  $(function() {
    graphShares24h();
    graphShares60m();
    return graphFound();
  });
}).call(this);
