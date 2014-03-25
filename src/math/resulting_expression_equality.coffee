#= require ./base
#= require lib
#= require lib/math/expression_components

ttm = thinkthroughmath
class_mixer = ttm.class_mixer
object_refinement = ttm.lib.object_refinement

class ResultingExpressionEquality
  initialize: ->
    @report_saved = false

  calculate: (@first, @second)->
    @_equality_results = @first == @second
    @

  isEqual: ->
    @_equality_results

  notEqualReport: (@a, @b, @not_eql_msg)->
    @report_saved = true

  saveFalseForReport: (value, a, b, msg)->
    if value
      true
    else
      @notEqualReport(a, b, msg) unless @report_saved
      false

class_mixer ResultingExpressionEquality

ResultingExpressionEquality.isEqual = (a,b)->
  ResultingExpressionEquality.build().calculate(a,b).isEqual()

ResultingExpressionEquality.equalityCalculation = (a,b)->
  ec = ResultingExpressionEquality.build()
  ec.calculate(a,b)
  ec

ttm.lib.math.ResultingExpressionEquality = ResultingExpressionEquality
