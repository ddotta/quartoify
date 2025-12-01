test_that("rtoqmd_dir converts all R scripts in a directory", {
  # Create a temporary directory structure
  temp_dir <- tempfile()
  dir.create(temp_dir)
  dir.create(file.path(temp_dir, "subdir"))
  
  # Create test R files
  writeLines(c("x <- 1", "y <- 2"), file.path(temp_dir, "script1.R"))
  writeLines(c("z <- 3", "w <- 4"), file.path(temp_dir, "script2.R"))
  writeLines(c("a <- 5", "b <- 6"), file.path(temp_dir, "subdir", "script3.R"))
  
  # Convert all scripts
  results <- rtoqmd_dir(temp_dir, render = FALSE)
  
  # Check that all QMD files were created
  expect_true(file.exists(file.path(temp_dir, "script1.qmd")))
  expect_true(file.exists(file.path(temp_dir, "script2.qmd")))
  expect_true(file.exists(file.path(temp_dir, "subdir", "script3.qmd")))
  
  # Check results data frame
  expect_equal(nrow(results), 3)
  expect_equal(sum(results$status == "success"), 3)
  
  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})

test_that("rtoqmd_dir handles non-recursive mode", {
  # Create a temporary directory structure
  temp_dir <- tempfile()
  dir.create(temp_dir)
  dir.create(file.path(temp_dir, "subdir"))
  
  # Create test R files
  writeLines(c("x <- 1"), file.path(temp_dir, "script1.R"))
  writeLines(c("y <- 2"), file.path(temp_dir, "subdir", "script2.R"))
  
  # Convert only top-level scripts
  results <- rtoqmd_dir(temp_dir, recursive = FALSE, render = FALSE)
  
  # Check that only top-level QMD was created
  expect_true(file.exists(file.path(temp_dir, "script1.qmd")))
  expect_false(file.exists(file.path(temp_dir, "subdir", "script2.qmd")))
  
  expect_equal(nrow(results), 1)
  
  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})

test_that("rtoqmd_dir handles exclude_pattern", {
  # Create a temporary directory
  temp_dir <- tempfile()
  dir.create(temp_dir)
  
  # Create test R files
  writeLines(c("x <- 1"), file.path(temp_dir, "script.R"))
  writeLines(c("y <- 2"), file.path(temp_dir, "test_script.R"))
  
  # Convert excluding test files (pattern matches full path)
  results <- rtoqmd_dir(temp_dir, 
                       exclude_pattern = "test_script\\.R$",
                       render = FALSE)
  
  # Check that only non-test file was converted
  expect_true(file.exists(file.path(temp_dir, "script.qmd")))
  expect_false(file.exists(file.path(temp_dir, "test_script.qmd")))
  
  expect_equal(nrow(results), 1)
  
  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})

test_that("rtoqmd_dir handles empty directory", {
  # Create an empty temporary directory
  temp_dir <- tempfile()
  dir.create(temp_dir)
  
  # Try to convert
  results <- rtoqmd_dir(temp_dir, render = FALSE)
  
  # Check empty results
  expect_equal(nrow(results), 0)
  
  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})

test_that("rtoqmd_dir handles non-existent directory", {
  # Try to convert non-existent directory
  expect_error(
    rtoqmd_dir("nonexistent_directory"),
    "Directory does not exist"
  )
})

test_that("rtoqmd_dir applies title_prefix correctly", {
  # Create a temporary directory
  temp_dir <- tempfile()
  dir.create(temp_dir)
  
  # Create test R file
  writeLines(c("x <- 1"), file.path(temp_dir, "analysis.R"))
  
  # Convert with title prefix
  results <- rtoqmd_dir(temp_dir, 
                       title_prefix = "Project: ",
                       render = FALSE)
  
  # Read the generated QMD and check title
  qmd_content <- readLines(file.path(temp_dir, "analysis.qmd"))
  expect_true(any(grepl('title: "Project: analysis"', qmd_content)))
  
  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})
