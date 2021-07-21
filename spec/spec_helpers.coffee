#= require lib/logger

ttm = thinkthroughmath

LOGGING_TYPE="silent"
window.logger = switch LOGGING_TYPE
  when "silent" then ttm.Logger.buildSilent(stringify_objects: false)
  when "verbose" then ttm.Logger.buildVerbose(stringify_objects: false)
  else ttm.Logger.buildProduction(stringify_objects: false)
class_mixer = ttm.class_mixer

(window || global).cursor = (thing)->
  thing.has_cursor = true
  thing

beforeEach ->
  jasmine.addMatchers(
    toBeInstanceOf: (util, customEqualityTesters)->
      return {
        compare: (actual, expected)->
          result = {}
          result.pass = actual && actual instanceof expected
          if actual == undefined
            result.message = "Expected undefined to be an instance of #{expected.name}"
          else
            result.message = "Expected #{actual.constructor.name}(#{jasmine.pp actual}) to be an instance of #{expected.name}"
          result
      }

    toBeAnEqualExpressionTo: (util, customEqualityTesters)->
      return {
          compare: (actual, expected)->
            result = {}

            if actual and expected
              @check = ttm.lib.math.ExpressionEquality.equalityCalculation(actual, expected)
              result.pass = @check.isEqual()
            else
              result.pass = false

            if @check.report_saved
              result.message = "Expected #{actual.toString()} to be equal to #{expected.toString()}"
              result.message += ", but failed on #{@check.a.toString()}, #{@check.b.toString()}, #{@check.not_eql_msg}"
            result
      }
  )