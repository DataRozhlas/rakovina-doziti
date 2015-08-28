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
    @element.html ''
    @element.selectAll \div.stage .data stages .enter!append \div
      ..attr \class (stage) -> "stage stage-#{stage.name.replace '+' '-'}"
      ..selectAll \div.term .data (.survivals) .enter!append \div
        ..attr \class \term
        ..style \left (survival) ~> "#{@xScale survival.termStart}%"
        ..style \width (survival) ~> "#{(@xScale survival.termEnd + 1) - (@xScale survival.termStart)}%"
        ..append \div
          ..attr \class "rate main"
          ..style \top (survival) ~> "#{@yScale survival.rate}px"
          ..append \span
            ..attr \class \label
            ..html (survival) -> "#{Math.round survival.rate * 100} %"
        ..append \div
          ..attr \class "rate bounds"
          ..style \top (survival) ~> "#{@yScale survival.rateHigh}px"
          ..style \height (survival) ~>
            "#{(@yScale survival.rateLow) - (@yScale survival.rateHigh)}px"
          ..append \div .attr \class "divider divider-1"
          ..append \div .attr \class "divider divider-2"
          ..append \div .attr \class "divider divider-3"
    @element.selectAll \div.term-label .data stages.0.survivals .enter!append \div
      ..attr \class \term-label
      ..style \left (survival) ~> "#{@xScale survival.termStart}%"
      ..style \width (survival) ~> "#{(@xScale survival.termEnd + 1) - (@xScale survival.termStart)}%"
      ..html -> "#{it.termStart}<br>–<br>#{it.termEnd}"
