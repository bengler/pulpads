# Connections to pebbles configured here
{ServiceSet} = require("pebbles").service

services = new ServiceSet(host: config?.pebbles?.host)
services.use
  pulp: 1

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
    $("##{target_element.attr('id')}_loader").remove()
    target_element.empty()
    loader = $("<iframe id='#{target_element.attr('id')}_loader' style='display: none'></iframe>")
    $("body").append(loader)
    frame = $("##{target_element.attr('id')}_loader")[0].contentWindow
    frame.document.write(@ads[placement])
    frame.document.write = (string) ->
      html = ""
      try
        html = $(string)
      catch error
        console.log "Tried to write invalid html: #{string}"
      target_element.append(html)

module.exports = PulpAds
