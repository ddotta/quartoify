# Title : Roxygen Documentation Example
# Author : Quartify Team
# Date : 2025-12-09

## Mathematical Functions ####

#' Add Two Numbers
#'
#' This function takes two numeric values and returns their sum.
#'
#' @param x A numeric value.
#' @param y A numeric value.
#'
#' @return A numeric value representing the sum of `x` and `y`.
#'
#' @examples
#' add_numbers(3, 5)   # returns 8
#' add_numbers(-2, 7)  # returns 5
#'
#' @export
add_numbers <- function(x, y) {
  x + y
}

#' Multiply Two Numbers
#'
#' This function multiplies two numeric values.
#'
#' @param a First number
#' @param b Second number
#' @return The product of a and b
#' @examples
#' multiply_numbers(4, 5)  # returns 20
#' @export
multiply_numbers <- function(a, b) {
  a * b
}

## String Functions ####

#' Convert Text to Uppercase
#'
#' Takes a character string and converts all letters to uppercase.
#'
#' @param text A character string to convert
#' @return The input string in uppercase
#' @examples
#' to_upper("hello world")  # returns "HELLO WORLD"
#' @export
to_upper <- function(text) {
  toupper(text)
}

# Regular comment without roxygen
result <- add_numbers(10, 20)
print(result)
