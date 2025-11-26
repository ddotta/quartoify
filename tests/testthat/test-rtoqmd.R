test_that("rtoqmd converts basic R script to Quarto markdown", {
  # Create a temporary R script
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  # Write test content
  writeLines(c(
    "library(dplyr)",
    "",
    "# ## Title 2",
    "",
    "# This is a comment",
    "",
    "iris |> count(Species)"
  ), temp_r)
  
  # Run conversion
  rtoqmd(temp_r, temp_qmd, title = "Test", author = "Tester")
  
  # Check output file exists
  expect_true(file.exists(temp_qmd))
  
  # Read output
  output <- readLines(temp_qmd)
  
  # Check YAML header
  expect_true(any(grepl("^---$", output)))
  expect_true(any(grepl('title: "Test"', output)))
  expect_true(any(grepl('author: "Tester"', output)))
  
  # Check header conversion
  expect_true(any(grepl("^## Title 2$", output)))
  
  # Check comment conversion
  expect_true(any(grepl("This is a comment", output)))
  
  # Check code block
  expect_true(any(grepl("```\\{\\.r\\}", output)))
  
  # Cleanup
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd handles multiple header levels", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "# ## Level 2",
    "# ### Level 3",
    "# #### Level 4",
    "# ##### Level 5",
    "# ###### Level 6",
    "x <- 1"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd)
  output <- readLines(temp_qmd)
  
  expect_true(any(grepl("^## Level 2$", output)))
  expect_true(any(grepl("^### Level 3$", output)))
  expect_true(any(grepl("^#### Level 4$", output)))
  expect_true(any(grepl("^##### Level 5$", output)))
  expect_true(any(grepl("^###### Level 6$", output)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd groups consecutive code lines", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "x <- 1",
    "y <- 2",
    "z <- x + y"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd)
  output <- readLines(temp_qmd)
  
  # Find code blocks
  code_start <- grep("```\\{\\.r\\}", output)
  code_end <- grep("^```$", output)
  
  # Should have one code block containing all three lines
  expect_equal(length(code_start), 1)
  expect_true(any(grepl("x <- 1", output)))
  expect_true(any(grepl("y <- 2", output)))
  expect_true(any(grepl("z <- x \\+ y", output)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd ignores roxygen comments", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "#' This is roxygen",
    "#' @param x A parameter",
    "# This is a regular comment",
    "foo <- function(x) x"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd)
  output <- readLines(temp_qmd)
  
  # Roxygen comments should not appear in output
  expect_false(any(grepl("This is roxygen", output)))
  expect_false(any(grepl("@param", output)))
  
  # Regular comment should appear
  expect_true(any(grepl("This is a regular comment", output)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd uses default output filename when not provided", {
  temp_r <- tempfile(fileext = ".R")
  expected_qmd <- sub("\\.R$", ".qmd", temp_r)
  
  writeLines("x <- 1", temp_r)
  
  rtoqmd(temp_r)
  
  expect_true(file.exists(expected_qmd))
  
  unlink(temp_r)
  unlink(expected_qmd)
})

test_that("rtoqmd throws error for non-existent input file", {
  expect_error(
    rtoqmd("nonexistent.R", "output.qmd"),
    "Input file does not exist"
  )
})

test_that("rtoqmd handles empty lines correctly", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "x <- 1",
    "",
    "",
    "y <- 2"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd)
  output <- readLines(temp_qmd)
  
  # Should group code despite empty lines between
  code_start <- grep("```\\{\\.r\\}", output)
  expect_equal(length(code_start), 1)
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd separates code blocks by comments", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "x <- 1",
    "# A comment",
    "y <- 2"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd)
  output <- readLines(temp_qmd)
  
  # Should have two separate code blocks
  code_start <- grep("```\\{\\.r\\}", output)
  expect_equal(length(code_start), 2)
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd customizes YAML header", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines("x <- 1", temp_r)
  
  rtoqmd(temp_r, temp_qmd, 
         title = "Custom Title",
         author = "Custom Author",
         format = "pdf")
  
  output <- readLines(temp_qmd)
  
  expect_true(any(grepl('title: "Custom Title"', output)))
  expect_true(any(grepl('author: "Custom Author"', output)))
  expect_true(any(grepl('format: pdf', output)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})
