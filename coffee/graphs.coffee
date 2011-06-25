graph = (div, urls, options) ->
  data = []

  $.plot(div, data, options)

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
    $.plot(div, data, options)

  for url in urls
    $.ajax({url: url, method: 'GET', dataType: 'json', success: onDataReceived})

graphShares = ->
  options = {
    lines: { fill: true, show: true },
    xaxis: { mode: "time", ticksize: [1, "hour"] },
  }

  urls = [
    "/graph/last_24h.json?label=Stale&r=stale",
    "/graph/last_24h.json?label=Valid&o=true",
  ]

  graph($("#graph-shares"), urls, options)

graphStales = ->
  options = {
    lines: { fill: true, show: true },
    xaxis: { mode: "time", ticksize: [1, "hour"] },
  }
  urls = ["/graph/last_24h.json?label=Stale&r=stale"]
  graph($("#graph-stales"), urls, options)

graphFound = ->
  options = {
    lines: { show: true },
    points: { show: true },
    xaxis: { mode: "time", tickSize: [1, "day"] },
    yaxis: { minTickSize: 1, tickSize: 1 },
  }
  urls = ["/graph/last_7d.json?label=Found&u=true&o=true"]
  graph($("#graph-found"), urls, options)

$ ->
  graphShares()
  graphStales()
  graphFound()
