$ = require("jquery")

class PulpAds
  constructor: (options) ->
    @pulp = options.pulp
    @realm = options.realm
    @publication = options.publication

  loadAds: ->
    dfd = $.Deferred()
    @pulp.get("/#{@realm}/publications/#{@publication}/adtech").then (ads) =>
      @ads = ads
      dfd.resolve(@ads)
    $('#apiBackgroundAd').attr("style", "")
    dfd

  Ad: (placement, target_element) ->
    target_element.empty()
    loader = $("<iframe id='#{target_element.attr('id')}_loader' style='display: none;'></iframe>")
    $("body").append(loader)
    frame = $("##{target_element.attr('id')}_loader")[0].contentWindow
    frame.document.open()
    frame.document.write "<body>#{@ads[placement]}</body>"
    buffer = ""
    last_buffer = "-"
    frame.top = window
    frame.window = window
    frame.parent = window
    interval = setInterval =>
        buffer = frame.document.body.innerHTML
        if last_buffer == buffer
          clearInterval(interval)
          buffer = buffer.replace(/<sc[r]ipt[\s\S]*?<\/sc[r]ipt>/gi,'').replace(/<style[\s\S]*?<\/style>/gi,'')
          target_element.html($(buffer))
          $("##{target_element.attr('id')}_loader").remove()
        else
          last_buffer = buffer
      , 50

module.exports = PulpAds
