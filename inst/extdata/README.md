# Example Datasets for longorwide Package

This directory contains example datasets to help users learn and test the functionality of the longorwide package.

## Datasets

### 1. example_wide.csv
Wide format data with repeated measures (3 time points)
- participant_id: Unique identifier
- age: Participant age
- condition: Experimental condition (control/treatment)
- time1, time2, time3: Scores at three time points

### 2. example_long.csv
Long format data (same data as example_wide but in long format)
- participant_id: Unique identifier
- age: Participant age
- condition: Experimental condition
- timepoint: Time point (time1/time2/time3)
- score: Measured score

### 3. example_qualtrics.csv
Simulated Qualtrics export with header rows
- Includes the typical Qualtrics header structure
- Contains reverse-coded items
- Multiple scales for reliability analysis

## Usage Examples

```r
library(longorwide)

# Load example wide data
wide_data <- read.csv(system.file("extdata", "example_wide.csv", package = "longorwide"))

# Convert to long
long_data <- wide_to_long(
  wide_data,
  id_cols = c("participant_id", "age", "condition"),
  value_cols = c("time1", "time2", "time3"),
  names_to = "timepoint",
  values_to = "score"
)

# Load example long data
long_data <- read.csv(system.file("extdata", "example_long.csv", package = "longorwide"))

# Convert to wide
wide_data <- long_to_wide(
  long_data,
  id_cols = c("participant_id", "age", "condition"),
  names_from = "timepoint",
  values_from = "score"
)

# Load example Qualtrics data
qualtrics_raw <- read.csv(system.file("extdata", "example_qualtrics.csv", package = "longorwide"))

# Process Qualtrics data
clean_data <- prepare_qualtrics(qualtrics_raw, remove_first_rows = 2)
clean_data <- reverse_score(clean_data, items = c("item2", "item4"), 
                            min_value = 1, max_value = 7)
```
