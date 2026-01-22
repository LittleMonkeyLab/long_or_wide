# Code Snippets for longorwide Package

This document provides ready-to-use code snippets for common tasks with the longorwide package.

## Installation

```r
# Install from GitHub
install.packages("devtools")
devtools::install_github("LittleMonkeyLab/long_or_wide")

# Load the package
library(longorwide)
```

## Quick Start Examples

### 1. Convert Wide to Long Format

```r
# Example: Repeated measures data
wide_data <- data.frame(
  participant_id = 1:30,
  age = sample(18:65, 30, replace = TRUE),
  baseline = rnorm(30, 100, 15),
  week_4 = rnorm(30, 105, 15),
  week_8 = rnorm(30, 110, 15),
  week_12 = rnorm(30, 115, 15)
)

# Convert to long format
long_data <- wide_to_long(
  wide_data,
  id_cols = c("participant_id", "age"),
  value_cols = c("baseline", "week_4", "week_8", "week_12"),
  names_to = "timepoint",
  values_to = "score"
)
```

### 2. Convert Long to Wide Format

```r
# Convert back to wide
wide_data_again <- long_to_wide(
  long_data,
  id_cols = c("participant_id", "age"),
  names_from = "timepoint",
  values_from = "score"
)
```

### 3. Qualtrics Workflow

```r
# Import Qualtrics CSV
raw_data <- read.csv("qualtrics_export.csv", stringsAsFactors = FALSE)

# Clean data (remove first 2 header rows)
clean_data <- prepare_qualtrics(raw_data, remove_first_rows = 2)

# Reverse score specific items (e.g., items on 1-7 scale)
clean_data <- reverse_score(
  clean_data,
  items = c("Q2", "Q4", "Q6", "Q8"),
  min_value = 1,
  max_value = 7
)

# Calculate composite scores
clean_data$positive_affect <- rowMeans(
  clean_data[, c("Q1", "Q3", "Q5", "Q7")],
  na.rm = TRUE
)

clean_data$negative_affect <- rowMeans(
  clean_data[, c("Q2", "Q4", "Q6", "Q8")],
  na.rm = TRUE
)
```

### 4. Between-Subjects T-Test

```r
# Two independent groups
data_between <- data.frame(
  condition = rep(c("control", "experimental"), each = 30),
  performance = c(
    rnorm(30, mean = 75, sd = 10),
    rnorm(30, mean = 82, sd = 10)
  )
)

# Run t-test
result <- run_ttest(
  data_between,
  design = "between",
  dv = "performance",
  iv = "condition"
)

# View results
print(result$result)
print(result$descriptives)
```

### 5. Within-Subjects (Paired) T-Test

```r
# Pre-post design
data_within <- data.frame(
  participant = 1:25,
  pre_test = rnorm(25, mean = 50, sd = 10),
  post_test = rnorm(25, mean = 58, sd = 10)
)

# Run paired t-test
result <- run_ttest(
  data_within,
  design = "within",
  group1 = "pre_test",
  group2 = "post_test"
)

print(result$result)
```

### 6. Multiple Trials T-Tests

```r
# Multiple time points
data_trials <- data.frame(
  trial_1 = rnorm(20, mean = 50, sd = 8),
  trial_2 = rnorm(20, mean = 52, sd = 8),
  trial_3 = rnorm(20, mean = 55, sd = 8),
  trial_4 = rnorm(20, mean = 57, sd = 8)
)

# Conduct all pairwise comparisons
result <- run_ttest(
  data_trials,
  design = "multiple_trials",
  trial_cols = c("trial_1", "trial_2", "trial_3", "trial_4")
)

# View all comparisons
names(result$results)
print(result$descriptives)
```

### 7. One-Way ANOVA

```r
# Three or more groups
data_anova <- data.frame(
  treatment = rep(c("placebo", "drug_A", "drug_B", "drug_C"), each = 25),
  symptom_reduction = c(
    rnorm(25, mean = 20, sd = 5),
    rnorm(25, mean = 30, sd = 5),
    rnorm(25, mean = 35, sd = 5),
    rnorm(25, mean = 40, sd = 5)
  )
)

# Run ANOVA
result <- run_anova(
  data_anova,
  design = "one_way",
  dv = "symptom_reduction",
  iv1 = "treatment"
)

print(result$anova_result)
print(paste("Effect size (eta squared):", round(result$eta_squared, 3)))

# Post-hoc tests
posthoc <- TukeyHSD(result$model)
print(posthoc)
```

### 8. Two-Way ANOVA

```r
# 2x2 factorial design
data_twoway <- data.frame(
  therapy = rep(c("CBT", "DBT"), each = 50),
  medication = rep(c("yes", "no"), 50),
  outcome = rnorm(100, mean = 50, sd = 10)
)

# Run two-way ANOVA
result <- run_anova(
  data_twoway,
  design = "two_way",
  dv = "outcome",
  iv1 = "therapy",
  iv2 = "medication"
)

print(result$anova_result)
```

### 9. Repeated Measures ANOVA

```r
# Within-subjects design with multiple time points
data_rm <- data.frame(
  subject_id = rep(1:25, each = 4),
  time = rep(c("T1", "T2", "T3", "T4"), 25),
  depression_score = rnorm(100, mean = 20, sd = 5)
)

# Run repeated measures ANOVA
result <- run_anova(
  data_rm,
  design = "repeated_measures",
  dv = "depression_score",
  subject_id = "subject_id",
  within_factor = "time"
)

print(result$anova_result)
```

### 10. Multiple Regression

```r
# Multiple predictors
data_regression <- data.frame(
  job_satisfaction = rnorm(100, mean = 50, sd = 10),
  work_hours = rnorm(100, mean = 40, sd = 8),
  salary = rnorm(100, mean = 50000, sd = 10000),
  autonomy = rnorm(100, mean = 5, sd = 1.5)
)

# Run regression
result <- run_multiple_regression(
  data_regression,
  dv = "job_satisfaction",
  predictors = c("work_hours", "salary", "autonomy")
)

print(result$summary)
```

### 11. Multiple Regression with Covariates

```r
# Controlling for demographic variables
data_covariate <- data.frame(
  depression = rnorm(100, mean = 15, sd = 5),
  social_support = rnorm(100, mean = 50, sd = 10),
  exercise = rnorm(100, mean = 3, sd = 1.5),
  age = sample(18:65, 100, replace = TRUE),
  sex = sample(c("male", "female"), 100, replace = TRUE)
)

# Run hierarchical regression
result <- run_multiple_regression(
  data_covariate,
  dv = "depression",
  predictors = c("social_support", "exercise"),
  covariates = c("age", "sex")
)

print(result$summary)
print(result$hierarchical_comparison)  # Test if predictors add beyond covariates
print(result$vif)  # Check for multicollinearity
```

### 12. Check Assumptions

```r
# Prepare data
data_assumptions <- data.frame(
  group = rep(c("A", "B", "C"), each = 30),
  score = c(
    rnorm(30, mean = 50, sd = 10),
    rnorm(30, mean = 55, sd = 10),
    rnorm(30, mean = 60, sd = 10)
  )
)

# Check all assumptions
assumptions <- check_assumptions(
  data_assumptions,
  dv = "score",
  group = "group"
)

# Normality by group
print(assumptions$normality_by_group)

# Homogeneity of variance
print(assumptions$homogeneity)
```

### 13. Descriptive Statistics

```r
# Overall descriptives
descriptives <- descriptive_stats(
  data_assumptions,
  vars = "score"
)
print(descriptives)

# By group
descriptives_group <- descriptive_stats(
  data_assumptions,
  vars = "score",
  group = "group"
)
print(descriptives_group)

# Multiple variables
multi_var_data <- data.frame(
  group = rep(c("A", "B"), each = 30),
  var1 = rnorm(60, mean = 50, sd = 10),
  var2 = rnorm(60, mean = 30, sd = 5),
  var3 = rnorm(60, mean = 70, sd = 15)
)

descriptives_multi <- descriptive_stats(
  multi_var_data,
  vars = c("var1", "var2", "var3"),
  group = "group"
)
print(descriptives_multi)
```

### 14. Cronbach's Alpha

```r
# Calculate reliability for a scale
scale_data <- data.frame(
  item1 = sample(1:7, 100, replace = TRUE),
  item2 = sample(1:7, 100, replace = TRUE),
  item3 = sample(1:7, 100, replace = TRUE),
  item4 = sample(1:7, 100, replace = TRUE),
  item5 = sample(1:7, 100, replace = TRUE),
  item6 = sample(1:7, 100, replace = TRUE)
)

alpha_result <- cronbach_alpha(
  scale_data,
  items = c("item1", "item2", "item3", "item4", "item5", "item6")
)

print(paste("Cronbach's alpha:", round(alpha_result$alpha, 3)))
print(paste("Standardized alpha:", round(alpha_result$standardized_alpha, 3)))

# Check which items might be problematic
print(alpha_result$alpha_if_dropped)
```

### 15. Complete Analysis Pipeline

```r
# Full workflow from Qualtrics to results
library(longorwide)

# 1. Load data
raw_data <- read.csv("qualtrics_export.csv", stringsAsFactors = FALSE)

# 2. Prepare Qualtrics data
clean_data <- prepare_qualtrics(raw_data, remove_first_rows = 2)

# 3. Reverse score negative items
clean_data <- reverse_score(
  clean_data,
  items = c("Q3", "Q5", "Q7", "Q9"),
  min_value = 1,
  max_value = 7
)

# 4. Calculate scale scores
scale_items <- paste0("Q", 1:10)
clean_data$scale_total <- rowMeans(clean_data[, scale_items], na.rm = TRUE)

# 5. Check reliability
reliability <- cronbach_alpha(clean_data, items = scale_items)
print(paste("Scale reliability (alpha):", round(reliability$alpha, 3)))

# 6. Get descriptive statistics
descriptives <- descriptive_stats(
  clean_data,
  vars = "scale_total",
  group = "condition"
)
print(descriptives)

# 7. Check assumptions
assumptions <- check_assumptions(
  clean_data,
  dv = "scale_total",
  group = "condition"
)
print(assumptions)

# 8. Run main analysis
if (length(unique(clean_data$condition)) == 2) {
  # T-test for 2 groups
  result <- run_ttest(
    clean_data,
    design = "between",
    dv = "scale_total",
    iv = "condition"
  )
} else {
  # ANOVA for 3+ groups
  result <- run_anova(
    clean_data,
    design = "one_way",
    dv = "scale_total",
    iv1 = "condition"
  )
}

print(result)
```

### 16. Launch Shiny App

```r
# Interactive data converter
run_converter_app()

# The app allows you to:
# - Upload CSV files
# - Interactively convert between wide and long formats
# - Preview both original and converted data
# - Generate R code for reproducibility
# - Download the converted data
```

## Tips and Best Practices

### Data Preparation
- Always check your data structure before conversion
- Ensure column names are consistent and meaningful
- Handle missing data appropriately before analysis
- Document your reverse scoring decisions

### Statistical Analysis
- Always check assumptions before running parametric tests
- Report effect sizes along with p-values
- For ANOVA with more than 2 groups, conduct post-hoc tests
- Check for multicollinearity in regression (VIF values)
- Consider the sample size requirements for your analysis

### Reliability
- Cronbach's alpha should typically be > 0.70 for research purposes
- Examine "alpha if item deleted" to identify problematic items
- Consider both raw and standardized alpha values

### Qualtrics Import
- Export data with numeric values when possible
- Keep the question text row if you need to map Q codes to questions
- Document any column renaming or data transformations
