stageIds =
  "I": 0
  "I+II": 0
  "II": 1
  "III": 2
  "IV": 3
  "celkem": null

stageIdsTreament =
  "1": 0
  "2": 1
  "3": 2
  "4": 3
  "Celkem": null

class ig.Diagnosis
  (@name) ->
    @stages = []
    @stageTotal = new Stage "Celkem"

  addSurvival: ({termStart, termEnd, stage, survival, survivalLow, survivalHigh}:data) ->
    stageId = stageIds[stage]
    if stageId == null
      @stageTotal.addSurvival data
    else
      if not @stages[stageId]
        @stages[stageId] = new Stage stage
      @stages[stageId].addSurvival data

  init: ->
    @stages .= filter -> it
    @stages.forEach (.init)
    @stageTotal.init!

  addTreatment: (stage, rate) ->
    stageId = stageIdsTreament[stage]
    if stageId == null
      @stageTotal.addTreatmentRate rate
    else
      @stages[stageId]?.addTreatmentRate rate


class Stage
  (@name) ->
    @survivals = []

  addSurvival: ({termStart, termEnd, survival, survivalHigh, survivalLow}) ->
    @survivals.push new Survival termStart, termEnd, survival, survivalHigh, survivalLow

  addTreatmentRate: (rate) ->
    @survivals[*-1].treatmentRate = rate

  init: ->
    @survivals.sort (a, b) -> a.termStart - b.termStart

class Survival
  (@termStart, @termEnd, @rate, @rateHigh, @rateLow) ->
    @treatmentRate = null
