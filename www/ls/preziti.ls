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

container = d3.select ig.containers.base

