class ig.Bar
  (@parentElement, @yScale) ->
    @element = @parentElement.append \div
      ..attr \class \bar
    @xScale = d3.scale.linear!
      ..domain [1990 2012]
      ..range [0 100]

  draw: (diagnosis) ->
    stages =
      | diagnosis.stages.length => diagnosis.stages
      | otherwise               => [diagnosis.stageTotal]
    @element.selectAll "div.stage:not(.exiting)" .data stages, (.name)
      ..enter!append \div
      ..exit!
        ..classed \exiting yes
        ..transition!
          ..delay 400
          ..remove!
      ..attr \class (stage) -> "stage stage-#{stage.name.replace '+' '-'}"
      ..selectAll "div.term:not(.exiting)" .data (.survivals), (.termStart)
        ..enter!append \div
          ..attr \class \term
          ..append \div
            ..attr \class "rate main"
            ..append \span
              ..attr \class \label
          ..append \div
            ..attr \class "rate bounds"
            ..append \div .attr \class "divider divider-1"
            ..append \div .attr \class "divider divider-2"
            ..append \div .attr \class "divider divider-3"
        ..exit!
          ..classed \exiting yes
          ..transition!
            ..delay 400
            ..remove!
        ..style \left (survival) ~> "#{@xScale survival.termStart}%"
        ..style \width (survival) ~> "#{(@xScale survival.termEnd + 1) - (@xScale survival.termStart)}%"
        ..select \div.rate.main
          ..style \top (survival) ~> "#{@yScale survival.rate}px"
          ..select \span.label
            ..html (survival) -> "#{Math.round survival.rate * 100} %"
        ..select \div.rate.bounds
          ..style \top (survival) ~> "#{@yScale survival.rateHigh}px"
          ..style \height (survival) ~>
            "#{(@yScale survival.rateLow) - (@yScale survival.rateHigh)}px"
    @element.selectAll \div.term-label .data stages.0.survivals .enter!append \div
      ..attr \class \term-label
      ..style \left (survival) ~> "#{@xScale survival.termStart}%"
      ..style \width (survival) ~> "#{(@xScale survival.termEnd + 1) - (@xScale survival.termStart)}%"
      ..html -> "#{it.termStart}<br>–<br>#{it.termEnd}"
