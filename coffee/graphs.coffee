graphShares60m = ->
  options = {
    lines: { show: true },
    points: { show: true },
    xaxis: { mode: "time", ticksize: [1, "minute"] },
  }
  data = []
  graph = $("#graph-shares-60m")

  $.plot(graph, data, options)

  # fetch one series, adding to what we got
  alreadyFetched = {}

  # then fetch the data with jQuery
  onDataReceived = (series) ->
    # extract the first coordinate pair so you can see that
    # data is now an ordinary Javascript object
    firstcoordinate = '(' + series.data[0][0] + ', ' + series.data[0][1] + ')'

    # let's add it to our current data
    unless alreadyFetched[series.label]
      alreadyFetched[series.label] = true
      data.push(series)

    # and plot all we got
    $.plot(graph, data, options)

  $.ajax({url: "/graph/last_60m.json?label=Stale&r=stale", method: 'GET', dataType: 'json', success: onDataReceived})
  $.ajax({url: "/graph/last_60m.json?label=Valid&o=true", method: 'GET', dataType: 'json', success: onDataReceived})

graphShares24h = ->
  options = {
    lines: { show: true },
    points: { show: true },
    xaxis: { mode: "time", ticksize: [1, "hour"] },
  }
  data = []
  graph = $("#graph-shares")

  $.plot(graph, data, options)

  # fetch one series, adding to what we got
  alreadyFetched = {}

  # then fetch the data with jQuery
  onDataReceived = (series) ->
    # extract the first coordinate pair so you can see that
    # data is now an ordinary Javascript object
    firstcoordinate = '(' + series.data[0][0] + ', ' + series.data[0][1] + ')'

    # let's add it to our current data
    unless alreadyFetched[series.label]
      alreadyFetched[series.label] = true
      data.push(series)

    # and plot all we got
    $.plot(graph, data, options)

  $.ajax({url: "/graph/last_24h.json?label=Stale&r=stale", method: 'GET', dataType: 'json', success: onDataReceived})
  $.ajax({url: "/graph/last_24h.json?label=Valid&o=true", method: 'GET', dataType: 'json', success: onDataReceived})

graphFound = ->
  options = {
    lines: { show: true },
    points: { show: true },
    xaxis: { mode: "time", ticksize: [1, "day"] },
    yaxis: { minTicksize: 1 },
  }
  data = []
  graph = $("#graph-found")

  $.plot(graph, data, options)

  # fetch one series, adding to what we got
  alreadyFetched = {}

  # then fetch the data with jQuery
  onDataReceived = (series) ->
    # extract the first coordinate pair so you can see that
    # data is now an ordinary Javascript object
    firstcoordinate = '(' + series.data[0][0] + ', ' + series.data[0][1] + ')'

    # let's add it to our current data
    unless alreadyFetched[series.label]
      alreadyFetched[series.label] = true
      data.push(series)

    # and plot all we got
    $.plot(graph, data, options)

  $.ajax({url: "/graph/last_7d.json?label=Found&u=true&o=true", method: 'GET', dataType: 'json', success: onDataReceived})

$ ->
  graphShares24h()
  graphShares60m()
  graphFound()
