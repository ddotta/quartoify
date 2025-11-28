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
  
  # Check code block and YAML execute options
  expect_true(any(grepl("```\\{r\\}", output)))
  expect_true(any(grepl("execute:", output)))
  expect_true(any(grepl("eval: false", output)))
  expect_true(any(grepl("echo: true", output)))
  
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
  code_start <- grep("```\\{r\\}", output)
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
  code_start <- grep("```\\{r\\}", output)
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
  code_start <- grep("```\\{r\\}", output)
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
  expect_true(any(grepl('format:', output)))
  expect_true(any(grepl('pdf:', output)))
  expect_true(any(grepl('embed-resources: true', output)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd handles markdown tables in comments", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "# Table example:",
    "# | fruit  | price  |",
    "# |--------|--------|",
    "# | apple  | 2.05   |",
    "# | pear   | 1.37   |",
    "",
    "x <- 1"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd, render = FALSE)
  output <- readLines(temp_qmd)
  
  # Check all table lines are present
  expect_true(any(grepl("Table example:", output)))
  expect_true(any(grepl("\\| fruit", output)))
  expect_true(any(grepl("\\|--------", output)))
  expect_true(any(grepl("\\| apple", output)))
  expect_true(any(grepl("\\| pear", output)))
  
  # Find consecutive comment lines (table should be together)
  # Look for the table example line and check following lines
  table_intro_line <- grep("Table example:", output)[1]
  
  # The next few lines should be the table without empty lines between them
  expect_true(grepl("\\| fruit", output[table_intro_line + 1]))
  expect_true(grepl("\\|--------", output[table_intro_line + 2]))
  expect_true(grepl("\\| apple", output[table_intro_line + 3]))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd number_sections parameter works correctly", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines("x <- 1", temp_r)
  
  # Test with number_sections = TRUE (default)
  rtoqmd(temp_r, temp_qmd, render = FALSE)
  output <- readLines(temp_qmd)
  expect_true(any(grepl("number-sections: true", output)))
  
  # Test with number_sections = FALSE
  rtoqmd(temp_r, temp_qmd, render = FALSE, number_sections = FALSE)
  output <- readLines(temp_qmd)
  expect_true(any(grepl("number-sections: false", output)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd extracts metadata from comments - French version", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "# Titre : Analyse des iris",
    "#",
    "# Auteur : Jean Dupont",
    "#",
    "# Date : 2025-11-28",
    "#",
    "# Description : Analyser les données iris",
    "#",
    "library(dplyr)",
    "x <- 1"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd, render = FALSE)
  output <- readLines(temp_qmd)
  
  # Check metadata is correctly extracted
  expect_true(any(grepl('title: "Analyse des iris"', output)))
  expect_true(any(grepl('author: "Jean Dupont"', output)))
  expect_true(any(grepl('date: "2025-11-28"', output)))
  expect_true(any(grepl('description: "Analyser les données iris"', output)))
  
  # Check metadata lines are not in the body of the document
  # (they should only be in YAML header)
  body_start <- grep("^---$", output)[2] + 1
  body_lines <- output[body_start:length(output)]
  expect_false(any(grepl("Titre :", body_lines)))
  expect_false(any(grepl("Auteur :", body_lines)))
  expect_false(any(grepl("Description :", body_lines)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd extracts metadata from comments - English version", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "# Title : Iris Analysis",
    "#",
    "# Author : John Doe",
    "#",
    "# Date : 2025-11-28",
    "#",
    "# Description : Analyze iris dataset",
    "#",
    "library(dplyr)",
    "x <- 1"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd, render = FALSE)
  output <- readLines(temp_qmd)
  
  # Check metadata is correctly extracted
  expect_true(any(grepl('title: "Iris Analysis"', output)))
  expect_true(any(grepl('author: "John Doe"', output)))
  expect_true(any(grepl('date: "2025-11-28"', output)))
  expect_true(any(grepl('description: "Analyze iris dataset"', output)))
  
  # Check metadata lines are not in the body
  body_start <- grep("^---$", output)[2] + 1
  body_lines <- output[body_start:length(output)]
  expect_false(any(grepl("Title :", body_lines)))
  expect_false(any(grepl("Author :", body_lines)))
  expect_false(any(grepl("Description :", body_lines)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd uses function parameters when no metadata in script", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  # Script without metadata comments
  writeLines(c(
    "library(dplyr)",
    "x <- 1"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd, 
         title = "Default Title",
         author = "Default Author",
         render = FALSE)
  output <- readLines(temp_qmd)
  
  # Should use function parameters
  expect_true(any(grepl('title: "Default Title"', output)))
  expect_true(any(grepl('author: "Default Author"', output)))
  
  # Should not have date or description
  expect_false(any(grepl("^date:", output)))
  expect_false(any(grepl("^description:", output)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd metadata overrides function parameters", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "# Title : Metadata Title",
    "# Author : Metadata Author",
    "x <- 1"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd, 
         title = "Function Title",
         author = "Function Author",
         render = FALSE)
  output <- readLines(temp_qmd)
  
  # Metadata should override function parameters
  expect_true(any(grepl('title: "Metadata Title"', output)))
  expect_true(any(grepl('author: "Metadata Author"', output)))
  expect_false(any(grepl('title: "Function Title"', output)))
  expect_false(any(grepl('author: "Function Author"', output)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})
