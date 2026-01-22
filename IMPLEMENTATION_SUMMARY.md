# longorwide Package Implementation Summary

## Overview
This document summarizes the complete implementation of the longorwide R package, which addresses all requirements from the problem statement.

## Problem Statement Requirements ✓

### 1. Wide Long Requirements ✓
**Status: Complete**
- `wide_to_long()`: Converts data from wide to long format
- `long_to_wide()`: Converts data from long to wide format
- Fully flexible with customizable column specifications
- Examples and documentation provided

### 2. Data Style for All Relevant Analyses ✓
**Status: Complete**
- Package supports both wide and long formats
- Automatic conversions between formats as needed
- Optimal data format guidelines documented in QUALTRICS_GUIDE.md

### 3. Shiny Converter and Code Snippets ✓
**Status: Complete**
- Interactive Shiny app at `inst/shiny-apps/converter/app.R`
- Launch with `run_converter_app()`
- Features:
  - CSV file upload
  - Interactive wide/long conversion
  - Real-time data preview
  - Automatic R code generation
  - Download converted data
- Comprehensive code snippets in CODE_SNIPPETS.md

### 4. Consider Qualtrics ✓
**Status: Complete**
- `prepare_qualtrics()`: Cleans Qualtrics exports
- Removes header rows automatically
- Handles numeric conversion
- Column mapping support
- Complete workflow documentation in QUALTRICS_GUIDE.md
- Example Qualtrics dataset provided

### 5. Reverse Scoring ✓
**Status: Complete**
- `reverse_score()`: Reverses item scores
- Supports multiple items simultaneously
- Flexible min/max values
- Examples with 5-point and 7-point scales

### 6. T-test Within Between with Multiple Trials ✓
**Status: Complete**
- `run_ttest()` with three designs:
  - **Between-subjects**: Independent groups t-test
  - **Within-subjects**: Paired/dependent t-test
  - **Multiple trials**: All pairwise comparisons
- Includes descriptive statistics with results

### 7. ANOVA x 3 ✓
**Status: Complete**
- `run_anova()` with three types:
  - **One-way ANOVA**: Single factor
  - **Two-way ANOVA**: Two factors with interaction
  - **Repeated measures ANOVA**: Within-subjects design
- Effect sizes (eta squared) calculated
- Post-hoc test ready

### 8. Multiple Regression and with Covariates ✓
**Status: Complete**
- `run_multiple_regression()`: Full regression analysis
- Supports multiple predictors
- Optional covariates for hierarchical regression
- Hierarchical model comparison
- VIF calculation for multicollinearity
- Optional standardization

### 9. Assumptions, Descriptives and Alphas ✓
**Status: Complete**
- `check_assumptions()`: 
  - Shapiro-Wilk normality test
  - Bartlett's homogeneity of variance test
  - By-group and overall testing
- `descriptive_stats()`:
  - n, mean, sd, min, max, median
  - Overall and by-group statistics
- `cronbach_alpha()`:
  - Cronbach's alpha coefficient
  - Standardized alpha
  - Item statistics
  - Alpha if item deleted

### 10. Assume Qualtrics Input and Specify Optimal Data Format ✓
**Status: Complete**
- QUALTRICS_GUIDE.md provides:
  - Survey design best practices
  - Optimal naming conventions
  - Export settings recommendations
  - Data structure examples for all designs
  - Complete workflows from Qualtrics to analysis

## Package Structure

```
longorwide/
├── DESCRIPTION              # Package metadata and dependencies
├── NAMESPACE               # Exported functions and imports
├── LICENSE                 # MIT License
├── README.md              # Main package documentation
├── CODE_SNIPPETS.md       # Ready-to-use code examples
├── QUALTRICS_GUIDE.md     # Qualtrics workflow guide
├── .gitignore             # Git ignore rules
│
├── R/                     # R source code
│   ├── data_transformation.R  # wide_to_long, long_to_wide
│   ├── qualtrics_utils.R     # prepare_qualtrics, reverse_score
│   ├── ttest.R               # run_ttest
│   ├── anova.R               # run_anova
│   ├── regression.R          # run_multiple_regression
│   ├── utils.R               # check_assumptions, descriptive_stats, cronbach_alpha
│   └── shiny_app.R          # run_converter_app
│
├── inst/
│   ├── shiny-apps/
│   │   └── converter/
│   │       └── app.R       # Interactive Shiny app
│   └── extdata/           # Example datasets
│       ├── README.md
│       ├── example_wide.csv
│       ├── example_long.csv
│       └── example_qualtrics.csv
│
├── tests/
│   ├── testthat.R
│   └── testthat/
│       ├── test-data_transformation.R
│       ├── test-qualtrics_utils.R
│       ├── test-ttest.R
│       └── test-utils.R
│
└── vignettes/
    └── introduction.Rmd    # Comprehensive tutorial
```

## Key Features

### Data Transformation
- Bidirectional conversion between wide and long formats
- Flexible column specification
- Preserves multiple ID columns
- Handles repeated measures designs

### Qualtrics Integration
- Automatic header removal
- Numeric conversion
- Column renaming
- Reverse scoring
- Optimal format guidelines

### Statistical Analyses
- **T-tests**: Between, within, multiple trials
- **ANOVA**: One-way, two-way, repeated measures
- **Regression**: Multiple predictors, covariates, hierarchical

### Utilities
- Assumption checking (normality, homogeneity)
- Descriptive statistics (overall and by-group)
- Reliability analysis (Cronbach's alpha)

### Interactive Tools
- Shiny app for data conversion
- Real-time preview
- Code generation
- CSV import/export

### Documentation
- Comprehensive README with examples
- Code snippet library
- Qualtrics workflow guide
- Vignette tutorial
- Example datasets

## Dependencies

### Required Packages
- tidyr (>= 1.2.0): Data transformation
- dplyr (>= 1.0.0): Data manipulation
- shiny (>= 1.7.0): Interactive app
- psych (>= 2.0.0): Reliability analysis
- car (>= 3.0.0): VIF calculation
- stats: Statistical tests
- readr (>= 2.0.0): Data import

### Suggested Packages
- testthat (>= 3.0.0): Testing
- knitr: Documentation
- rmarkdown: Vignettes

## Installation

```r
# Install from GitHub
devtools::install_github("LittleMonkeyLab/long_or_wide")

# Load package
library(longorwide)
```

## Usage Examples

### Basic Workflow
```r
# 1. Load data
data <- read.csv("survey_data.csv")

# 2. Clean Qualtrics export
data <- prepare_qualtrics(data, remove_first_rows = 2)

# 3. Reverse score items
data <- reverse_score(data, items = c("item2", "item4"), 
                     min_value = 1, max_value = 7)

# 4. Calculate scale scores
data$scale_score <- rowMeans(data[, paste0("item", 1:5)], na.rm = TRUE)

# 5. Check reliability
alpha <- cronbach_alpha(data, items = paste0("item", 1:5))

# 6. Check assumptions
assumptions <- check_assumptions(data, dv = "scale_score", group = "condition")

# 7. Run analysis
result <- run_ttest(data, design = "between", 
                   dv = "scale_score", iv = "condition")

# 8. Get descriptives
desc <- descriptive_stats(data, vars = "scale_score", group = "condition")
```

### Interactive Conversion
```r
# Launch Shiny app
run_converter_app()
```

## Testing

The package includes comprehensive tests for:
- Data transformation (wide/long conversion)
- Qualtrics utilities (cleaning, reverse scoring)
- Statistical tests (t-tests)
- Utility functions (descriptives, alpha)

Run tests with:
```r
devtools::test()
```

## Documentation Access

```r
# Package help
?longorwide

# Function help
?wide_to_long
?run_ttest
?run_anova

# Vignette
vignette("introduction", package = "longorwide")
```

## Summary

✅ **All problem statement requirements have been fully implemented**

The longorwide package provides a complete solution for:
- Data transformation between wide and long formats
- Qualtrics data processing and preparation
- Comprehensive statistical analyses
- Interactive data conversion tools
- Extensive documentation and examples

The package is production-ready with:
- 11 exported functions covering all requirements
- Comprehensive documentation and examples
- Interactive Shiny app
- Example datasets
- Unit tests
- Multiple guides and tutorials

Users can now:
1. Import and clean Qualtrics data
2. Reverse score items
3. Convert between wide and long formats
4. Check statistical assumptions
5. Calculate descriptive statistics and reliability
6. Run t-tests, ANOVAs, and regressions
7. Use an interactive app for conversions
8. Access ready-to-use code snippets
