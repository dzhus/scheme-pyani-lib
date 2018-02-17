# pyani-lib

This package provides several Scheme libraries of different purposes.
It originates from some code I wanted to share across some of my
programs. This package is compatible with Racket.

## Features

Notice: in January 2009 I discovered [simple-matrix][] package, which
provided superior implementations for most of the functions
`pyani-lib` had, so I decided to remove most of the existing code.

- simple vector and matrix norms

- `pyani-lib/function-ops`: derivatives (total and partial), gradient
  and Hessian matrix calculation.

## Installation

Invoking `make` in top-level directory will build a package with
`.plt` extension. It may installed with `make install` or manually
using `raco(1)`.

## Usage

You'll want to use the following modules under `pyani-lib` collection:
`function-ops`, `vector`, `matrix`.

## To do

- [ ] Use contracts.

      Contracts good, bugs bad.

- [ ] Strip tests from .plt archive

[simple-matrix]: http://planet.plt-scheme.org/display.ss?package=simple-matrix.plt&owner=wmfarr
