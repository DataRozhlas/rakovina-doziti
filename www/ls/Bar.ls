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
          ..attr \class -> "term term-#{it.termStart}"
          ..append \div
            ..attr \class "rate main"
            ..append \span
              ..attr \class \label
          ..append \div
            ..attr \class "rate bounds"
            ..append \div .attr \class "divider divider-1"
            ..append \div .attr \class "divider divider-2"
            ..append \div .attr \class "divider divider-3"
            ..append \div
              ..attr \class "treatment-bar"
            ..append \span
              ..attr \class "treatment-label"

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
          ..select \div.treatment-bar
            ..style \height -> "#{(it.treatmentRate || 0)* 100}%"
          ..select \span.treatment-label
            ..html ->
              if it.treatmentRate is null
                void
              else
                "#{Math.round it.treatmentRate * 100} %<br>léčených"
    @element.append \div .attr \class \term-labels
        ..selectAll \div.term-label .data stages.0.survivals .enter!append \div
          ..attr \class \term-label
          ..style \left (survival) ~> "#{@xScale survival.termStart}%"
          ..style \width (survival) ~> "#{(@xScale survival.termEnd + 1) - (@xScale survival.termStart)}%"
          ..html -> "#{it.termStart}<br>–<br>#{it.termEnd}"
