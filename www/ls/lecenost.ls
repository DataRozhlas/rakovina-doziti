return unless window.location.hash == '#lecenost'
container = d3.select ig.containers.base
element = container.select \.preziti
  ..attr \class "preziti lecenost"

element
  ..select \h2
    ..html "Některé rakoviny mají téměř 100% úspěšnost léčby"
  ..select \h3
    ..html "Nejvíce záleží na stádiu, v níž se nemoc objeví. V posledních fázích je šance na přežití mnohem nižší, často se vůbec nezahajuje léčba."

graph = element.selectAll \svg.graph
diagnosesAssoc = ig.diagnosesAssoc

ig.slope.y2Label (gElement) ->
  gElement.append \text
    ..text ->
      "#{Math.round it.datum.stageTotal.survivals[*-1].rate * 100} % #{it.datum.name}"
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

ig.slope
  ..margin {left: 20, right: 270, top: 130, bottom: 0}
  ..draw!

ig.bar.yScale = ig.slope.scale
