#= require ./base
#= require lib
#= require lib/math/expression_components

ttm = thinkthroughmath
class_mixer = ttm.class_mixer
object_refinement = ttm.lib.object_refinement

ref = object_refinement.build()
comps = ttm.lib.math.ExpressionComponentSource.build()

buildIsEqual = (for_type, additional_method=false)->
  isEqualFunction = (other, eq_calc)->
    same_type = (other instanceof for_type)
    eq_calc.saveFalseForReport(same_type, @unrefined(), other,
      "different types #{for_type.name}")
    if same_type
      if additional_method
        @[additional_method](other, eq_calc)
      else
        true
    else
      false
  ttm.logger.instrument(name: "buildIsEqual function", fn: isEqualFunction)

# Blank
ref.forType(comps.classes.blank, {
  isEqual: (buildIsEqual(comps.classes.blank))
  })

# Number
ref.forType(comps.classes.number, {
  isEqual: (buildIsEqual(comps.classes.number, "checkNumberValues")),
  checkNumberValues: (other, eq_calc)->

    check = parseFloat("#{@value()}") == parseFloat("#{other.value()}")
    eq_calc.saveFalseForReport(check, @unrefined(), other, "Numeric values not equal")
})

ref.forDefault({
  isEqual: ->
    throw ["Unimplemented equality refinement for ", @unrefined()]
})

class ResultingExpressionEquality
  initialize: ->
    @report_saved = false

  calculate: (@first, @second)->
    firstp = ref.refine @first
    @_equality_results = firstp.isEqual @second, @
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
