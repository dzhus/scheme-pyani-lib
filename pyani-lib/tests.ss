#lang scheme

(require (planet schematics/schemeunit:3)
         (planet schematics/schemeunit:3/text-ui))

(require "matrix-tests.ss"
         "vector-tests.ss"
         "generic-ops-tests.ss"
         "function-ops-tests.ss")

(exit (run-tests (test-suite "All tests"
                             matrix-tests
                             vector-tests
                             generic-ops-tests
                             function-ops-tests)))
