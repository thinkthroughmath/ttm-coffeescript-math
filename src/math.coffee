# this is the central point of organization for the math library
# TODO rename this to 'SlideRule'

# # Tests
# The entire SlideRule test suite may be run in your browser by visiting
# [the jasmine test runner page](SpecRunner.html)

# # Features

# For an overview of the features of the entire library,
# see the
# [features spec](features_spec.html),
# which is written to demonstrate this library in action.

# # Requirements
#
# * ttm-coffeescript-utilities -- used for ClassMixer, Refinements library
# * underscore.js -- used for everything
#
# TODO rename ttm-coffeescript-utilities

# # Code

ttm = thinkthroughmath
ttm.lib.math ||= {}

# we require all component libraries

require './math/precise'
require './math/expression_components'
require './math/expression_equality'
require './math/expression_evaluation'
require './math/expression_manipulation'
require './math/expression_position'
require './math/build_expression_from_javascript_object'
require './math/expression_traversal'
require './math/expression_to_string'




# The MathLib Class
# =================
#
# MathLib is a class which represents the entire math library 'system'.
# Using a class and instance here lets us override various components,
# which is super useful for testing.
class MathLib

  initialize: (opts={})->


    # ## Precision

    # A library for doing 'precise'
    # (i.e. not-hindered-by-floating-point-garbage)
    # math. It is slow, hacky, and awful, but it *does* work for our
    # purposes.
    #
    # See the
    # [precise library](./precise.html)
    # and the
    # [precise library specs](./precise_spec.html)
    precise = opts.precise || ttm.lib.math.Precise.build()

    # ## 'Components'

    # represent the various components of an expression.
    # (e.g. 'numbers', 'variables', 'exponentiations')
    #
    # See the
    # [components library](./precise.html)
    # and the
    # [components library specs](./precise_spec.html)
    comps = opts.comps || ttm.lib.math.ExpressionComponentSource.build(precise)
    @components = opts.components || comps
    @equation = opts.equation || comps.equation
    @expression = opts.expression || comps.expression



    # ## Expression Position

    # Expression Position acts like an editing "pointer", which "points" into the
    # expression tree at where the expression is being edited.
    @expression_position = opts.expression_position || ttm.lib.math.ExpressionPosition


    # ## ExpressionTraversal

    # Since 'Expression' objects are complicated things,
    # ExpressionTraversal provides a way to 'traverse' them and
    # examine them.
    #
    # See the
    # [expression traversal library](./expression_traversal.html)
    # and the
    # [expression traversal library specs](./expression_traversal_spec.html)

    @traversal = opts.traversal || ttm.lib.math.ExpressionTraversalBuilder.build(comps.classes)


    # ## Commands

    # Commands act upon existing expressions
    # there is a foo, there is a bar, there is a baz
    @commands = opts.commands || ttm.lib.math.ExpressionManipulationSource.build(comps, @expression_position, @traversal)



    # ## Misc

    # A number of other miscellanious components
    @object_to_expression = opts.object_to_expression || ttm.lib.math.BuildExpressionFromJavascriptObject.build(component_builder: @components)

    # Evaluation is used to "evaluate" an expression,
    # converting it into another expression
    @evaluation = opts.evaluation || ttm.lib.math.ExpressionEvaluation


    # Expression equality is used to determine if an expression is considered equal
    @expression_equality = opts.expression_equality || ttm.lib.math.ExpressionEquality


# Export the math library class
ttm.lib.math.math_lib = ttm.class_mixer MathLib





