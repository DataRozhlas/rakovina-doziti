return unless window.location.hash in ['#preziti' '#lecenost']

ig.diagnosesAssoc = diagnosesAssoc = {}
ig.diagnoses      = diagnoses      = []
data = d3.tsv.parse ig.data.preziti, (row) ->
  diagnosis = row['Diagnóza, skupina diagnóz']
  [termStart, termEnd] = row['Období'].split "-" .map parseInt _, 10
  stage = row['Stadium']
  survival = parseFloat row['5leté relativní přežití']
  survivalLow = parseFloat row['dolní interval spolehlivosti']
  survivalHigh = parseFloat row['horní interval spolehlivosti']
  if diagnosesAssoc[diagnosis]
    dg = that
  else
    diagnosesAssoc[diagnosis] = dg = new ig.Diagnosis diagnosis
    diagnoses.push dg
  dg.addSurvival {termStart, termEnd, stage, survival, survivalLow, survivalHigh}
  row

data = d3.tsv.parse ig.data.lecenost, (row) ->
  name = row['Diagnóza']
  if diagnosesAssoc[name]
    diagnosesAssoc[name].addTreatment do
      row['stadium']
      parseFloat row['2008-2011']
  row

diagnoses.forEach (.init!)

diagnosesAssoc['Štítná žláza'].yOffset = -5
diagnosesAssoc['Varle'].yOffset = 5
diagnosesAssoc['Melanom kůže'].yOffset = -8
diagnosesAssoc['Prs - ženy'].yOffset = 5
diagnosesAssoc['Předstojná žláza - prostata'].yOffset = -2
diagnosesAssoc['Hodgkinův lymfom'].yOffset = 7
diagnosesAssoc['Děloha'].yOffset = 8
diagnosesAssoc['Hrdlo děložní - cervicis uteri'].yOffset = -2
diagnosesAssoc['Jícen'].yOffset = -4
diagnosesAssoc['Průdušnice, průdušky a plíce'].yOffset = 4
diagnosesAssoc['Žlučník a žlučové cesty'].yOffset = 6
diagnosesAssoc['Slinivka břišní'].yOffset = 14

container = d3.select ig.containers.base
element = container.append \div
  ..attr \class \preziti




class PrezitiSlope extends ig.Slope
  _getVoronoiGeneratingPoints: ->
    voronoiGeneratingPoints = []
    for line in @linePointCoords
      voronoiGeneratingPoints.push {x: line.x1, y: line.y1, point: line.datum}
      voronoiGeneratingPoints.push {x: line.x2, y: line.y2 + (line.datum.yOffset || 0), point: line.datum}
      voronoiGeneratingPoints.push {x: (line.x2 + line.x1) / 2, y: (line.y1 + line.y2) / 2, point: line.datum}
    voronoiGeneratingPoints

  highlight: (diagnosis) ->
    @labelsEnd.classed \active -> it.datum is diagnosis

ig.slope = slope = new PrezitiSlope element
  ..y (diagnosis) ->
    y1 = diagnosis.stageTotal.survivals.0.rate
    y2 = diagnosis.stageTotal.survivals.[* - 1].rate
    [y1, y2]
  ..margin {left: 20, right: 250, top: 100, bottom: 55}
  ..y1Label null
  ..y2Label (gElement) ->
      gElement.append \text
        ..text -> it.datum.name
        ..attr \x 20
        ..attr \dy 4
        ..attr \y -> it.datum.yOffset || 0
      gElement
        ..append \line
          ..attr \x1 6
          ..attr \x2 11
        ..append \line
          ..attr \y2 (.datum.yOffset)
          ..attr \x1 11
          ..attr \x2 11
        ..append \line
          ..attr \y1 (.datum.yOffset)
          ..attr \y2 (.datum.yOffset)
          ..attr \x1 11
          ..attr \x2 16
  ..x1Label.append \text
    ..text "1990"
    ..attr \text-anchor \middle
    ..attr \y 14
  ..x2Label.append \text
    ..text "2010"
    ..attr \text-anchor \middle
    ..attr \y 14
  ..scaleExtent (yValues) -> [0, d3.max yValues]
  ..setData diagnoses
if window.location.hash is'#preziti'
  slope.draw!

ig.bar = bar = new ig.Bar slope.element, slope.scale

slope
  ..on \mouseover (diagnosis) ->
    bar.draw diagnosis
    element.classed \bar-active yes
    slope.highlight diagnosis
  ..on \mouseout (diagnosis) ->
    element.classed \bar-active no
    slope.highlight null


element
  ..append \h2
    ..html "Pravděpodobnost přežití většiny druhů rakoviny se zvýšila"
  ..append \h3
    ..html "Výjimkou jsou nemoci zjišťované v pozdních stádiích, například rakoviny hrtanu nebo mozku"
  ..append \div
    ..attr \class "bar legend"
    ..append \div
      ..attr \class "stage stage-I"
      ..append \div
        ..attr \class "rate main"
        ..append \span
          ..attr \class \label
          ..html "1. stadium"
      ..append \div
        ..attr \class "rate bounds"
        ..append \div .attr \class "divider divider-1"
        ..append \div .attr \class "divider divider-2"
        ..append \div .attr \class "divider divider-3"
    ..append \div
      ..attr \class "stage stage-II"
      ..append \div
        ..attr \class "rate main"
        ..append \span
          ..attr \class \label
          ..html "2. stadium"
      ..append \div
        ..attr \class "rate bounds"
        ..append \div .attr \class "divider divider-1"
        ..append \div .attr \class "divider divider-2"
        ..append \div .attr \class "divider divider-3"
    ..append \div
      ..attr \class "stage stage-III"
      ..append \div
        ..attr \class "rate main"
        ..append \span
          ..attr \class \label
          ..html "3. stadium"
      ..append \div
        ..attr \class "rate bounds"
        ..append \div .attr \class "divider divider-1"
        ..append \div .attr \class "divider divider-2"
        ..append \div .attr \class "divider divider-3"
    ..append \div
      ..attr \class "stage stage-IV"
      ..append \div
        ..attr \class "rate main"
        ..append \span
          ..attr \class \label
          ..html "4. stadium"
      ..append \div
        ..attr \class "rate bounds"
        ..append \div .attr \class "divider divider-1"
        ..append \div .attr \class "divider divider-2"
        ..append \div .attr \class "divider divider-3"
    ..append \div
      ..attr \class "stage stage-Celkem"
      ..append \div
        ..attr \class "rate main"
        ..append \span
          ..attr \class \label
          ..html "všechna stádia"
      ..append \div
        ..attr \class "rate bounds"
        ..append \div .attr \class "divider divider-1"
        ..append \div .attr \class "divider divider-2"
        ..append \div .attr \class "divider divider-3"
    ..append \div
      ..attr \class \confidence-extent
    ..append \span
      ..attr \class \confidence-label
      ..html "interval spolehlivosti 95%"
