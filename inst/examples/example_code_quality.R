# Title : Code Quality Example
# Author : quartify
# Date : 2025-12-08
# Description : This example demonstrates styler and lintr integration

## Data Preparation ====

# Load packages
library(dplyr)

# Here we have some code with style issues
x = 3 # Should use <- instead of =
y <- 2
z<-10 # Missing spaces around <-

## Data Analysis ====

# Calculate statistics
mean_value<-mean(c(x,y,z)) # Missing spaces

# Create a vector with inconsistent spacing
my_vector<-c(1,2,3,4,5)

## Visualization ====

# callout-note - Style Issues
# This script intentionally contains several style issues:
# - Using = instead of <- for assignment
# - Missing spaces around operators
# - Inconsistent spacing in function calls
#
# Run with use_styler = TRUE to see the automatically styled version
# Run with use_lintr = TRUE to see the linting issues

# Plot data
plot(my_vector,main="My Plot",xlab="Index",ylab="Value")

## Results ====

# Print results
cat("Mean value:",mean_value,"\n")
