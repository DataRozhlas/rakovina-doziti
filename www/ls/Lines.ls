class ig.Lines
  (@parentElement, @data) ->
    width = 227px
    height = 640px
    padding = {top: 5 right: 11 bottom: 27 left: 47}
    innerWidth = width - padding.left - padding.right
    innerHeight = height - padding.top - padding.bottom

    @xScale = d3.scale.linear!
      ..domain [0, 17]
      ..range [0, innerWidth]

    barWidth = innerWidth / (@xScale.domain!.1 - @xScale.domain!.0)
    @data.forEach (line) ->
      extent = d3.extent line.data.map (.y)
      min = max = line.data.0
      for datum in line.data
        max = datum if datum.y > max.y
        min = datum if datum.y < min.y
      line.yExtent = [min.y, max.y]
      line.significantYPoints = [max]

    @yScale = y = d3.scale.linear!
      ..domain [0 1519]
      ..range [innerHeight, 0]

    paths = @data.map (line, i) ~>
      d3.svg.line!
        ..x ~> @xScale it.x
        ..y ~> @yScale it.y
    @parentElement.selectAll \.line .data @data .enter!append \div
      ..attr \class \line
      ..append \h3
        ..html (.title)
      ..append \div
        ..attr \class \horizontal-extent
      ..append \svg
        ..attr \width width
        ..attr \height (line) ~> height - @yScale line.max
        ..append \g
          ..attr \transform (line) ~> "translate(0, #{-1 * @yScale line.max})"
          ..append \g
            ..attr \transform "translate(#{padding.left},#{padding.top})"
            ..attr \class \active-lines
            ..append \line
              ..attr \class \horizontal
              ..attr \x1 -13
            ..append \line
              ..attr \class \vertical
              ..attr \y2 innerHeight + 13
          ..append \g
            ..attr \class \drawing
            ..attr \transform "translate(#{padding.left},#{padding.top})"
            ..append \path
              ..attr \d ({data}, i) -> paths[i] data
            ..selectAll \circle.point .data (.data) .enter!append \circle
              ..attr \class \point
              ..classed \significant (d, i, ii) ~> d in @data[ii].significantYPoints
              ..attr \cx ({x, y}, i, ii) ~> @xScale x
              ..attr \cy ({x, y}, i, ii) ~> @yScale y
              ..attr \r 3
          ..append \g
            ..attr \class "axis x"
            ..attr \transform "translate(#{padding.left},#{height - 15})"
            ..append \line
              ..attr \class \full-extent
              ..attr \x1 -10
              ..attr \x2 innerWidth + padding.right
            ..append \line
              ..attr \class \extent
              ..attr \x1 (d, i) ~> @xScale d.data.0.x
              ..attr \x2 (d, i) ~> @xScale d.data[*-1].x
            ..selectAll \line.mark .data (.data) .enter!append \line
              ..attr \class \mark
              ..classed \significant (d, i, ii) ~> d in @data[ii].significantYPoints
              ..attr \x1 (d, i, ii) ~> @xScale d.x
              ..attr \x2 (d, i, ii) ~> @xScale d.x
              ..attr \y2 3
            ..selectAll \text.significant .data (.significantYPoints) .enter!append \text
              ..attr \class \significant
              ..attr \text-anchor \middle
              ..text -> it.label.replace ' let' ''
              ..attr \y 15
              ..attr \x (d, i, ii) ~> @xScale d.x
            ..append \text
              ..attr \class \active-text
              ..attr \text-anchor \middle
              ..attr \y 15
          ..append \g
            ..attr \class "axis y"
            ..attr \transform "translate(37,#{padding.top})"
            ..append \line
              ..attr \class \full-extent
              ..attr \y1 0
              ..attr \y2 innerHeight + 10
            ..append \line
              ..attr \class \extent
              ..attr \y1 (d, i) ~> @yScale d.yExtent.0
              ..attr \y2 (d, i) ~> @yScale d.yExtent.1
            ..selectAll \line.mark .data (-> it.data ++ it.significantYPoints) .enter!append \line
              ..attr \class \mark
              ..classed \significant (d, i, ii) ~> d in @data[ii].significantYPoints
              ..attr \x1 0
              ..attr \x1 -3
              ..attr \y1 (d, i, ii) ~> @yScale d.y
              ..attr \y2 (d, i, ii) ~> @yScale d.y
            ..selectAll \text.significant .data (.significantYPoints) .enter!append \text
              ..attr \class \significant
              ..text (d, i, ii) ~> @createText d, @data[ii]
              ..attr \y (d, i, ii) ~> @yScale d.y
              ..attr \dy 3
              ..attr \x -7
              ..attr \text-anchor \end
            ..append \text
              ..attr \class \active-text
              ..attr \dy 3
              ..attr \x -7
              ..attr \text-anchor \end
          ..append \g
            ..attr \transform "translate(#{padding.left},#{padding.top})"
            ..attr \class \interaction
            ..selectAll \rect .data ((d, i) ~> [@xScale.domain!0 to @xScale.domain!1]) .enter!append \rect
              ..attr \width barWidth
              ..attr \x (d, i, ii) ~> (@xScale d) - barWidth / 2
              ..attr \height innerHeight + 30
              ..attr \y -5
              ..on \mouseover ~> @highlight it
              ..on \tochstart ~> @highlight it
              ..on \mouseout @~downlight
    @svg = @parentElement.selectAll \svg
    @circles = @svg.selectAll \circle
    @activeLineHorizontal = @svg.selectAll ".active-lines .horizontal"
    @activeLineVertical   = @svg.selectAll ".active-lines .vertical"
    @activeTextX = @svg.selectAll ".axis.x text.active-text"
    @activeTextY = @svg.selectAll ".axis.y text.active-text"

  highlight: (x) ->
    @svg.classed \active yes
    @circles.classed \active (.x == x)
    points = @data.map (line) ->
      line.data.filter (-> it.x == x) .pop! || null

    @activeLineHorizontal
      ..filter ((d, _, i) -> points[i])
        ..classed \active yes
        ..attr \x2 (d, _, i) ~> @xScale points[i].x
        ..attr \y1 (d, _, i) ~> @yScale points[i].y
        ..attr \y2 (d, _, i) ~> @yScale points[i].y

    @activeLineVertical
      ..filter ((d, _, i) -> points[i])
        ..classed \active yes
        ..attr \y1 (d, _, i) ~> @yScale points[i].y
        ..attr \x1 (d, _, i) ~> @xScale points[i].x
        ..attr \x2 (d, _, i) ~> @xScale points[i].x

    @activeTextX
      ..filter ((d, _, i) -> points[i])
        ..classed \active yes
        ..attr \x (d, _, i) ~>
          xCoord = @xScale x
          if x == 17
            xCoord -= 7
          xCoord
        ..text (d, _, i) -> points[i].label
    @activeTextY
      ..filter ((d, _, i) -> points[i])
        ..classed \active yes
        ..attr \y (d, _, i) ~> @yScale points[i].y
        ..text (d, _, i) ~> @createText points[i], @data[i]

  downlight: ->
    @parentElement
      .selectAll \.active
      .classed \active no

  createText: (point, line) ->
    decimals =
      | point.y > 100 => 0
      | point.y > 10 => 1
      | otherwise => 2
    ig.utils.formatNumber point.y, decimals
