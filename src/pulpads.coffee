$ = require("jquery")

# Connections to pebbles configured here
{ServiceSet} = require("pebbles").service

services = new ServiceSet(host: config?.pebbles?.host)
services.use
  pulp: 1

class PulpAds
  constructor: (@realm, @publication) ->

  loadAds: ->
    dfd = $.Deferred()
    services.pulp.get("/#{@realm}/publications/#{@publication}/adtech").then (ads) =>
      @ads = ads
      dfd.resolve(@ads)
    $('#apiBackgroundAd').attr("style", "")
    dfd
  Ad: (placement, target_element) ->
    write = document.write
    container = $("<div id='#{target_element.attr('id')}_tmp' style='display: none'></div>")
    $('body').append(container)
    window.document.write = (string) =>
      try
        html = $(string)
      catch error
        return console.log error
      src = html.attr("src")
      if src and html[0].tagName == "SCRIPT"
        $.getScript(src, =>
          setTimeout =>
            target_element.html(container.html())
            window.document.write = write
            container.remove()
          , 1000
        )
      else
        container.append(html)
    container.append(@ads[placement])

module.exports = PulpAds
