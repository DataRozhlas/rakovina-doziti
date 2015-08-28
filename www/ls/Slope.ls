class ig.Slope
  (@parentElement) ->
    @_setDefaults!
    @_prepareElements!
    ig.Events @

  setData: (@data) ->
    allYValues = []
    linePointYs = for datum in @data
      pointY = @ycb datum
      allYValues.push pointY.0, pointY.1
      pointY

    @scale = d3.scale.linear!
      ..domain @scaleExtentCb allYValues
      ..range [@fullHeight - @marginObj.bottom, @marginObj.top]

    @linePointCoords = for yValues, i in linePointYs
      x1 = @marginObj.left
      x2 = @marginObj.left + @width
      [y1, y2] = yValues.map @scale
      datum = @data[i]
      {x1, x2, y1, y2, datum}

  y: (@ycb) ->

  x1: (@x1Position) ->

  x2: (@x2Position) ->

  y1Label: (@y1LabelCb) ->

  y2Label: (@y2LabelCb) ->

  margin: (@marginObj) ->
    @_calculateInnerDimensions!

  scaleExtent: (@scaleExtentCb) ->

  draw: ->
    @_drawGraph!
    @_drawInteractive!


  _drawGraph: ->
    linesG = @graphContainer.append \g
      ..attr \class \lines
    lines = linesG.selectAll \g.line .data @linePointCoords .enter!append \g
      ..attr \class \line
      ..append \line
        ..attr \x1 (.x1)
        ..attr \x2 (.x2)
        ..attr \y1 (.y1)
        ..attr \y2 (.y2)
      ..append \circle
        ..attr \cx (.x1)
        ..attr \cy (.y1)
        ..attr \r 3
      ..append \circle
        ..attr \cx (.x2)
        ..attr \cy (.y2)
        ..attr \r 3
    @labelsStart = lines.append \g
      ..attr \class "label label-start"
      ..attr \transform -> "translate(#{it.x1}, #{it.y1})"
    @labelsEnd = lines.append \g
      ..attr \class "label label-end"
      ..attr \transform -> "translate(#{it.x2}, #{it.y2})"

    @y1LabelCb @labelsStart if @y1LabelCb
    @y2LabelCb @labelsEnd   if @y2LabelCb

  _drawInteractive: ->
    voronoiGeneratingPoints = @_getVoronoiGeneratingPoints!
    voronoi = d3.geom.voronoi!
      ..x (.x)
      ..y (.y)
      ..clipExtent [[0, 0], [@fullWidth, @fullHeight]]
    voronoiPolygons = voronoi voronoiGeneratingPoints
      .filter -> it
    @interactiveContainer.selectAll \path .data voronoiPolygons .enter!append \path
      ..attr \d polygon
      ..on \mouseover ~> @emit \mouseover it.point.point
      ..on \touchstart ~> @emit \mouseover it.point.point
      ..on \mouseout ~> @emit \mouseout it.point.point
      ..on \click ~>
        @emit \click it.point.point

  _getVoronoiGeneratingPoints: ->
    voronoiGeneratingPoints = []
    for line in @linePointCoords
      voronoiGeneratingPoints.push {x: line.x1, y: line.y1, point: line.datum}
      voronoiGeneratingPoints.push {x: line.x2, y: line.y2, point: line.datum}
      voronoiGeneratingPoints.push {x: (line.x2 + line.x1) / 2, y: (line.y1 + line.y2) / 2, point: line.datum}
    voronoiGeneratingPoints

  _setDefaults: ->
    @ycb = -> [it.y1, it.y2]
    @scaleExtentCb = d3.extent
    @y1LabelCb = (gElement) ->
      gElement.append \text
        ..text (point) -> point.datum.label
    @y2LabelCb = (gElement) ->
      gElement.append \text
        ..text (point) -> point.datum.label
    @fullWidth = @parentElement.node!clientWidth
    @fullHeight = @parentElement.node!clientHeight
    @marginObj = top: 0 right: 0 bottom: 0 left: 0
    @_calculateInnerDimensions!

  _calculateInnerDimensions: ->
    @width = @fullWidth - @marginObj.left - @marginObj.right
    @height = @fullHeight - @marginObj.top - @marginObj.bottom
    if @x1Label
      that.attr \transform "translate(#{@marginObj.left}, #{@marginObj.top + @height})"
    if @x2Label
      that.attr \transform "translate(#{@marginObj.left + @width}, #{@marginObj.top + @height})"

  _prepareElements: ->
    @element = @parentElement.append \div
      ..attr \class \slope

    @graphContainer = @element.append \svg
      ..attr \class \graph
      ..attr {width: @fullWidth, height: @fullHeight}
    xLabelsG = @graphContainer.append \g
      ..attr \class "labels-x"
    @x1Label = xLabelsG.append \g
        ..attr \class "label label-x1"
        ..attr \transform "translate(0, #{@height})"
    @x2Label = xLabelsG.append \g
        ..attr \class "label label-x2"
        ..attr \transform "translate(#{@width}, #{@height})"

    @interactiveContainer = @element.append \svg
      ..attr \class \interactive
      ..attr {width: @fullWidth, height: @fullHeight}

polygon = -> "M#{it.join "L"}Z"
