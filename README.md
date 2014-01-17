# Slide Rule

A Coffeescript Mathematics Library developed internally at Think
Through Math.

Slide Rule is a library for creating and manipulating mathematical
expressions.
It consists of an object library that represents the AST, and a number
of classes that allow for manipulating these expressions.

Think Through Math uses it for the logic that is built into the
Javascript Calculator
and a few other components in its mathematics application.

## Installation

Download the [production version][min] or the [development version][max].

## Features


### DSL for creating expressions

There is a DSL for creating expressions from javascript objects:

    EXP = @mathLib.object_to_expression.buildExpressionFunction()

## Development

Install dependenices:

    npm install
    bower install

To run the tests:

    grunt test

To develop in a browser, run:

    grunt watch-serve

and then visit the served page in your browser.

To compile the

## License

MIT


[min]: https://raw.github.com/thinkthroughmath/ttm-coffeescript-math/master/dist/ttm-coffeescript-math.min.js
[max]: https://raw.github.com/thinkthroughmath/ttm-coffeescript-math/master/dist/ttm-coffeescript-math.js

