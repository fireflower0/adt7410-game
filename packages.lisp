(ql:quickload "cffi")
(ql:quickload "lispbuilder-sdl")

(defpackage :cl-cffi
  (:use :common-lisp
        :cffi
        :lispbuilder-sdl))

