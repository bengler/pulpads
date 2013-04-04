$ = require("jquery")

class PulpAds
  constructor: (options) ->
    @pulp = options.pulp
    @realm = options.realm
    @publication = options.publication
    @key = options.key
    @placements = options.placements
    @timings = {}
  loadAds: ->
    dfd = $.Deferred()
    url = "/#{@realm}/publications/#{@publication}/adtech"
    params = []
    if @key
      params.push "key=#{@key}"
    if @placements
      params.push "placements=#{@placements.join(',')}"
    if params.length > 0
      url += "?#{params.join('&')}"
    @pulp.get(url).then (ads) =>
      @ads = ads
      dfd.resolve(@ads)
    $('#apiBackgroundAd').attr("style", "")
    dfd

  updateNow: (placement) ->
    @timings[placement] = new Date()

  Ad: (placement, target_element) ->
    unless target_element and target_element.length > 0
      console.log "No target container for ad #{placement}"
      return
    target_element.html("")
    if $("apiBackgroundAd").lenth > 0
      $("apiBackgroundAd").style({})
    loader = $("<iframe id='#{target_element.attr('id')}_loader' style='display: none;'></iframe>")
    $("body").append(loader)
    frame = loader[0].contentWindow
    frame.document.x_write = frame.document.write
    frame.document.write = (string) =>
      @updateNow(placement)
      frame.document.x_write string
      @updateNow(placement)
    frame.document.write "<body>#{@ads[placement]}</body>"

    render = =>
      buffer = frame.document.body.innerHTML.replace(/<sc[r]ipt[\s\S]*?<\/sc[r]ipt>/gi,'').replace(/<!--[\s\S]*?-->/gi,'').replace(/^\s+|\s+$/g,'')
      buffer_html = $("<p></p>")
      try
        buffer_html = $(buffer)
      catch error
      if target_element.html() != buffer and buffer_html.children().length > 0
        target_element.html(buffer)
      else if buffer_html.children().length < 1
        $(frame.document.body).trigger("load")
    if frame.document.addEventListener
      frame.document.addEventListener("load", =>
        render()
      , true)
      frame.document.addEventListener("domSubtreeModified", =>
        render()
      , true)
    # IE 8 fallback
    else
      interval = setInterval =>
        if new Date() - @timings[placement] > 1000
          clearInterval(interval)
          setTimeout =>
            render()
          , 500
      , 5

module.exports = PulpAds
