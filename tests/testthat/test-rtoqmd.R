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

test_that("rtoqmd converts roxygen comments to callouts", {
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
  
  # Roxygen comments should be converted to callout-note
  expect_true(any(grepl("callout-note", output)))
  expect_true(any(grepl("Documentation - foo", output)))
  expect_true(any(grepl("This is roxygen", output)))
  expect_true(any(grepl("@param", output)))
  
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
         author = "Custom Author")
  
  output <- readLines(temp_qmd)
  
  expect_true(any(grepl('title: "Custom Title"', output)))
  expect_true(any(grepl('author: "Custom Author"', output)))
  expect_true(any(grepl('format:', output)))
  expect_true(any(grepl('html:', output)))
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

test_that("rtoqmd converts callout-note with title", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "# callout-note - This is a note",
    "# This is the content of the note",
    "# It can have multiple lines",
    "",
    "x <- 1"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd, render = FALSE)
  output <- readLines(temp_qmd)
  
  expect_true(any(grepl('^::: \\{\\.callout-note title="This is a note"\\}$', output)))
  expect_true(any(grepl("This is the content of the note", output)))
  expect_true(any(grepl("It can have multiple lines", output)))
  expect_true(any(grepl("^:::$", output)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd converts callout-tip without title", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "# callout-tip",
    "# Here is a useful tip",
    "",
    "x <- 1"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd, render = FALSE)
  output <- readLines(temp_qmd)
  
  expect_true(any(grepl("^::: \\{\\.callout-tip\\}$", output)))
  expect_true(any(grepl("Here is a useful tip", output)))
  expect_true(any(grepl("^:::$", output)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd converts callout-warning with title", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "# callout-warning - Important Warning",
    "# Be careful with this operation",
    "",
    "x <- 1"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd, render = FALSE)
  output <- readLines(temp_qmd)
  
  expect_true(any(grepl('^::: \\{\\.callout-warning title="Important Warning"\\}$', output)))
  expect_true(any(grepl("Be careful with this operation", output)))
  expect_true(any(grepl("^:::$", output)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd converts callout-caution with title", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "# callout-caution - Proceed with Caution",
    "# This may cause unexpected results",
    "",
    "x <- 1"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd, render = FALSE)
  output <- readLines(temp_qmd)
  
  expect_true(any(grepl('^::: \\{\\.callout-caution title="Proceed with Caution"\\}$', output)))
  expect_true(any(grepl("This may cause unexpected results", output)))
  expect_true(any(grepl("^:::$", output)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd converts callout-important without title", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "# callout-important",
    "# This is very important information",
    "# Do not ignore this",
    "",
    "x <- 1"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd, render = FALSE)
  output <- readLines(temp_qmd)
  
  expect_true(any(grepl("^::: \\{\\.callout-important\\}$", output)))
  expect_true(any(grepl("This is very important information", output)))
  expect_true(any(grepl("Do not ignore this", output)))
  expect_true(any(grepl("^:::$", output)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd handles multiple callouts in same file", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "# callout-note - First Note",
    "# Content of first note",
    "",
    "x <- 1",
    "",
    "# callout-tip - Second Tip",
    "# Content of second tip",
    "",
    "y <- 2"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd, render = FALSE)
  output <- readLines(temp_qmd)
  
  expect_true(any(grepl('^::: \\{\\.callout-note title="First Note"\\}$', output)))
  expect_true(any(grepl("Content of first note", output)))
  expect_true(any(grepl('^::: \\{\\.callout-tip title="Second Tip"\\}$', output)))
  expect_true(any(grepl("Content of second tip", output)))
  expect_equal(sum(grepl("^:::$", output)), 2)
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd handles multi-line description", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  writeLines(c(
    "# Title : Test Title",
    "#",
    "# Author : Test Author",
    "#",
    "# Description : This is a long description",
    "#   that continues on the second line",
    "#   and even on a third line",
    "#",
    "",
    "x <- 1"
  ), temp_r)
  
  rtoqmd(temp_r, temp_qmd, render = FALSE)
  output <- readLines(temp_qmd)
  
  # Check that description is present and concatenated
  desc_line <- output[grepl("^description:", output)]
  expect_length(desc_line, 1)
  expect_true(grepl("This is a long description", desc_line))
  expect_true(grepl("that continues on the second line", desc_line))
  expect_true(grepl("and even on a third line", desc_line))
  
  # Check that description lines are not in the body
  body_start <- which(grepl("^---$", output))[2] + 1
  body <- output[body_start:length(output)]
  expect_false(any(grepl("This is a long description", body)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})

test_that("rtoqmd removes trailing symbols from section titles", {
  temp_r <- tempfile(fileext = ".R")
  temp_qmd <- tempfile(fileext = ".qmd")
  
  # Create R script with various trailing symbols
  writeLines(c(
    "## Section with hash ####",
    "x <- 1",
    "",
    "## Section with many hashes ##################",
    "y <- 2",
    "",
    "### Section with equals ====",
    "z <- 3",
    "",
    "### Section with many equals ====================",
    "a <- 4",
    "",
    "#### Section with dashes ----",
    "b <- 5",
    "",
    "#### Section with many dashes --------------------",
    "c <- 6",
    "",
    "## Mixed symbols with hash ====",
    "d <- 7",
    "",
    "### Mixed symbols with equals ----",
    "e <- 8",
    "",
    "#### Mixed symbols with dashes ####",
    "f <- 9"
  ), temp_r)
  
  # Convert to Quarto
  rtoqmd(temp_r, output_file = temp_qmd, title = "Test", author = "Test Author")
  
  # Read output
  output <- readLines(temp_qmd)
  
  # Check that titles don't contain trailing symbols
  expect_true(any(output == "## Section with hash"))
  expect_true(any(output == "## Section with many hashes"))
  expect_true(any(output == "### Section with equals"))
  expect_true(any(output == "### Section with many equals"))
  expect_true(any(output == "#### Section with dashes"))
  expect_true(any(output == "#### Section with many dashes"))
  expect_true(any(output == "## Mixed symbols with hash"))
  expect_true(any(output == "### Mixed symbols with equals"))
  expect_true(any(output == "#### Mixed symbols with dashes"))
  
  # Verify that no trailing symbols remain in titles
  title_lines <- grep("^#{2,4}\\s+", output, value = TRUE)
  expect_false(any(grepl("#{4,}\\s*$", title_lines)))
  expect_false(any(grepl("={4,}\\s*$", title_lines)))
  expect_false(any(grepl("-{4,}\\s*$", title_lines)))
  
  unlink(temp_r)
  unlink(temp_qmd)
})
