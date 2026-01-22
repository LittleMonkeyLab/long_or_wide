# longorwide: Data Transformation and Statistical Analysis Tools

An R package for converting between wide and long data formats, importing and processing Qualtrics data, and conducting common statistical analyses. Includes an interactive Shiny app for data conversion.

## Features

- **Data Transformation**: Convert between wide and long formats
- **Qualtrics Support**: Import and prepare Qualtrics survey data
- **Reverse Scoring**: Easily reverse score survey items
- **Statistical Tests**: 
  - T-tests (within-subjects, between-subjects, multiple trials)
  - ANOVA (one-way, two-way, repeated measures)
  - Multiple regression with covariates
- **Utilities**: 
  - Assumption checking (normality, homogeneity of variance)
  - Descriptive statistics
  - Cronbach's alpha reliability
- **Shiny App**: Interactive data converter with code generation

## Installation

```r
# Install from GitHub
# install.packages("devtools")
devtools::install_github("LittleMonkeyLab/long_or_wide")
```

## Quick Start

### Data Transformation

```r
library(longorwide)

# Wide to Long
wide_data <- data.frame(
  id = 1:3,
  time1 = c(10, 12, 11),
  time2 = c(15, 14, 16),
  time3 = c(20, 19, 21)
)

long_data <- wide_to_long(
  wide_data, 
  id_cols = "id",
  value_cols = c("time1", "time2", "time3"),
  names_to = "timepoint",
  values_to = "score"
)

# Long to Wide
wide_data_back <- long_to_wide(
  long_data,
  id_cols = "id",
  names_from = "timepoint",
  values_from = "score"
)
```

### Qualtrics Data

```r
# Import Qualtrics CSV
qualtrics_data <- read.csv("survey_data.csv")

# Clean and prepare
clean_data <- prepare_qualtrics(
  qualtrics_data, 
  remove_first_rows = 2
)

# Reverse score items
clean_data <- reverse_score(
  clean_data,
  items = c("item2", "item4", "item6"),
  min_value = 1,
  max_value = 5
)
```

### Statistical Analyses

#### T-Tests

```r
# Between-subjects t-test
data_between <- data.frame(
  group = rep(c("Control", "Treatment"), each = 20),
  score = c(rnorm(20, 10, 2), rnorm(20, 12, 2))
)

result <- run_ttest(
  data_between,
  design = "between",
  dv = "score",
  iv = "group"
)

print(result$result)
print(result$descriptives)

# Within-subjects t-test
data_within <- data.frame(
  pre = rnorm(20, 10, 2),
  post = rnorm(20, 12, 2)
)

result <- run_ttest(
  data_within,
  design = "within",
  group1 = "pre",
  group2 = "post"
)

# Multiple trials
data_trials <- data.frame(
  trial1 = rnorm(20, 10, 2),
  trial2 = rnorm(20, 11, 2),
  trial3 = rnorm(20, 12, 2)
)

result <- run_ttest(
  data_trials,
  design = "multiple_trials",
  trial_cols = c("trial1", "trial2", "trial3")
)
```

#### ANOVA

```r
# One-way ANOVA
data_oneway <- data.frame(
  group = rep(c("A", "B", "C"), each = 20),
  score = c(rnorm(20, 10, 2), rnorm(20, 12, 2), rnorm(20, 14, 2))
)

result <- run_anova(
  data_oneway,
  design = "one_way",
  dv = "score",
  iv1 = "group"
)

# Two-way ANOVA
data_twoway <- data.frame(
  factor1 = rep(c("A", "B"), each = 40),
  factor2 = rep(c("X", "Y"), 40),
  score = rnorm(80, 10, 2)
)

result <- run_anova(
  data_twoway,
  design = "two_way",
  dv = "score",
  iv1 = "factor1",
  iv2 = "factor2"
)

# Repeated measures ANOVA
data_rm <- data.frame(
  subject = rep(1:20, each = 3),
  time = rep(c("T1", "T2", "T3"), 20),
  score = rnorm(60, 10, 2)
)

result <- run_anova(
  data_rm,
  design = "repeated_measures",
  dv = "score",
  subject_id = "subject",
  within_factor = "time"
)
```

#### Multiple Regression

```r
# Simple multiple regression
data_reg <- data.frame(
  y = rnorm(50, 10, 2),
  x1 = rnorm(50, 5, 1),
  x2 = rnorm(50, 3, 1),
  x3 = rnorm(50, 7, 1.5)
)

result <- run_multiple_regression(
  data_reg,
  dv = "y",
  predictors = c("x1", "x2", "x3")
)

# With covariates
data_cov <- data.frame(
  y = rnorm(50, 10, 2),
  predictor1 = rnorm(50, 5, 1),
  predictor2 = rnorm(50, 3, 1),
  age = rnorm(50, 30, 5),
  gender = sample(c("M", "F"), 50, replace = TRUE)
)

result <- run_multiple_regression(
  data_cov,
  dv = "y",
  predictors = c("predictor1", "predictor2"),
  covariates = c("age", "gender")
)

# Examine results
print(result$summary)
print(result$hierarchical_comparison)
print(result$vif)  # Check for multicollinearity
```

### Utilities

#### Check Assumptions

```r
# Check normality and homogeneity
data_check <- data.frame(
  group = rep(c("A", "B", "C"), each = 30),
  score = c(rnorm(30, 10, 2), rnorm(30, 12, 2), rnorm(30, 14, 2))
)

assumptions <- check_assumptions(
  data_check,
  dv = "score",
  group = "group"
)

print(assumptions$normality_by_group)
print(assumptions$homogeneity)
```

#### Descriptive Statistics

```r
# Overall descriptives
stats <- descriptive_stats(
  data_check,
  vars = "score"
)

# By group
stats_by_group <- descriptive_stats(
  data_check,
  vars = "score",
  group = "group"
)
```

#### Cronbach's Alpha

```r
# Scale reliability
scale_data <- data.frame(
  item1 = sample(1:5, 50, replace = TRUE),
  item2 = sample(1:5, 50, replace = TRUE),
  item3 = sample(1:5, 50, replace = TRUE),
  item4 = sample(1:5, 50, replace = TRUE)
)

alpha_result <- cronbach_alpha(
  scale_data,
  items = c("item1", "item2", "item3", "item4")
)

print(paste("Cronbach's alpha:", round(alpha_result$alpha, 3)))
print(alpha_result$item_statistics)
```

### Shiny App

Launch the interactive data converter:

```r
run_converter_app()
```

The app allows you to:
- Upload CSV files
- Convert between wide and long formats
- Preview original and converted data
- Generate R code for the conversion
- Download converted data

## Optimal Data Format for Qualtrics

When starting from scratch with Qualtrics, use this format:

### Survey Design
- Use clear, consistent column names (e.g., `item_1`, `item_2` instead of auto-generated codes)
- Group related items with consistent prefixes
- Mark items that need reverse scoring clearly

### Expected CSV Structure
```
ResponseID, item_1, item_2_rev, item_3, item_4_rev, item_5, ...
R_xxx,      4,       2,          5,       1,          3,      ...
```

### Preparation Steps
1. Export from Qualtrics as CSV
2. Use `prepare_qualtrics()` to remove header rows
3. Use `reverse_score()` for reverse-coded items
4. Transform to long format if needed for repeated measures analyses

## Code Snippets

### Complete Analysis Pipeline

```r
library(longorwide)

# 1. Import and prepare Qualtrics data
raw_data <- read.csv("qualtrics_export.csv")
clean_data <- prepare_qualtrics(raw_data, remove_first_rows = 2)

# 2. Reverse score items
clean_data <- reverse_score(
  clean_data,
  items = c("item2", "item4", "item6"),
  min_value = 1,
  max_value = 7
)

# 3. Calculate scale scores (if needed)
clean_data$scale_score <- rowMeans(
  clean_data[, c("item1", "item2", "item3", "item4", "item5", "item6")],
  na.rm = TRUE
)

# 4. Check reliability
alpha <- cronbach_alpha(
  clean_data,
  items = c("item1", "item2", "item3", "item4", "item5", "item6")
)

# 5. Get descriptives
desc <- descriptive_stats(clean_data, vars = "scale_score", group = "condition")

# 6. Check assumptions
assumptions <- check_assumptions(clean_data, dv = "scale_score", group = "condition")

# 7. Run analysis
result <- run_ttest(
  clean_data,
  design = "between",
  dv = "scale_score",
  iv = "condition"
)

# Or ANOVA if more than 2 groups
result <- run_anova(
  clean_data,
  design = "one_way",
  dv = "scale_score",
  iv1 = "condition"
)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details.