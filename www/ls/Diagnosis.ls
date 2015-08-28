stageIds =
  "I": 0
  "I+II": 0
  "II": 1
  "III": 1
  "IV": 3
  "celkem": null

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


class Stage
  (@name) ->
    @survivals = []

  addSurvival: ({termStart, termEnd, survival, survivalHigh, survivalLow}) ->
    @survivals.push new Survival termStart, termEnd, survival, survivalHigh, survivalLow

  init: ->
    @survivals.sort (a, b) -> a.termStart - b.termStart

class Survival
  (@termStart, @termEnd, @rate, @rateHigh, @rateLow) ->
