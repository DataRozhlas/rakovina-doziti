return unless window.location.hash == '#preziti'

diagnosesAssoc = {}
diagnoses = []
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

slope = new PrezitiSlope element
  ..y (diagnosis) ->
    y1 = diagnosis.stageTotal.survivals.0.rate
    y2 = diagnosis.stageTotal.survivals.[* - 1].rate
    [y1, y2]
  ..margin {left: 20, right: 250, top: 30, bottom: 15}
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
  ..draw!
