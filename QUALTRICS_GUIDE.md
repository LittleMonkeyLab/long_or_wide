# Optimal Qualtrics Data Format Guide

## Overview

This guide provides best practices for structuring Qualtrics surveys and exporting data to work optimally with the `longorwide` package and general data analysis workflows.

## Survey Design Best Practices

### 1. Question Naming Conventions

**Use Clear, Consistent Names:**
```
✓ Good: item_1, item_2, item_3
✓ Good: satisfaction_1, satisfaction_2, satisfaction_3
✗ Bad: Q1.1, QID23, Q2_3_TEXT
```

**Group Related Items:**
```
- anxiety_1, anxiety_2, anxiety_3, anxiety_4
- depression_1, depression_2, depression_3, depression_4
- stress_1, stress_2, stress_3, stress_4
```

**Mark Reverse-Coded Items:**
```
- wellbeing_1
- wellbeing_2_rev
- wellbeing_3
- wellbeing_4_rev
```

### 2. Scale Types

**Consistent Response Scales:**
- Use the same scale throughout a measure
- Document the scale range (e.g., 1-5, 1-7)
- Be consistent with labeling (e.g., 1 = Strongly Disagree, 7 = Strongly Agree)

**Recommended Scales:**
```
5-point Likert: 1 (Strongly Disagree) to 5 (Strongly Agree)
7-point Likert: 1 (Strongly Disagree) to 7 (Strongly Agree)
Visual Analog: 0-100
Binary: 0/1 or 1/2
```

### 3. Metadata Fields

**Always Include:**
```
- ResponseId (automatic)
- StartDate (automatic)
- EndDate (automatic)
- Progress (automatic)
- Duration (in seconds) (automatic)
```

**Recommended Custom Fields:**
```
- participant_id: Unique identifier
- condition: Experimental condition
- session: Session number (for repeated measures)
- experimenter: Who collected the data
```

## Export Settings

### 1. Recommended Export Options

**In Qualtrics:**
1. Go to Data & Analysis
2. Click "Export & Import" → "Export Data"
3. Select "CSV" format
4. Choose "Use numeric values" for multiple choice/scale questions
5. Include "Download all fields"
6. Export with "Choice Text" or "Numeric Value" as needed

### 2. Export Format

**Standard CSV Export Structure:**
```
Row 1: ImportId, ImportId, ImportId, ...
Row 2: Question text, Question text, ...
Row 3+: Actual data
```

**The longorwide package handles this automatically with:**
```r
clean_data <- prepare_qualtrics(raw_data, remove_first_rows = 2)
```

## Optimal Data Structure Examples

### Example 1: Between-Subjects Design

**Survey Structure:**
```
Fields:
- participant_id
- condition (control, treatment)
- age
- gender
- item_1 through item_10
- item_2_rev, item_4_rev, item_6_rev (reverse coded)
```

**Exported CSV (after header rows):**
```csv
participant_id,condition,age,gender,item_1,item_2_rev,item_3,item_4_rev,item_5,item_6_rev,item_7,item_8,item_9,item_10
1,control,25,F,5,2,4,3,5,1,4,4,5,4
2,treatment,28,M,6,1,5,2,6,2,5,5,6,5
3,control,22,F,4,3,3,4,4,3,3,4,4,3
```

**Processing Code:**
```r
library(longorwide)

# Import and clean
data <- read.csv("survey_export.csv")
data <- prepare_qualtrics(data, remove_first_rows = 2)

# Reverse score
data <- reverse_score(
  data,
  items = c("item_2_rev", "item_4_rev", "item_6_rev"),
  min_value = 1,
  max_value = 7
)

# Calculate scale score
scale_items <- paste0("item_", c(1, "2_rev", 3, "4_rev", 5, "6_rev", 7:10))
data$scale_score <- rowMeans(data[, scale_items], na.rm = TRUE)

# Analyze
result <- run_ttest(data, design = "between", dv = "scale_score", iv = "condition")
```

### Example 2: Within-Subjects/Repeated Measures

**Survey Structure (Multiple Time Points):**

**Option A: Separate Surveys (Recommended)**
```
Survey 1 (Baseline):
- participant_id
- session: "baseline"
- item_1 through item_10

Survey 2 (Follow-up):
- participant_id
- session: "followup"
- item_1 through item_10
```

**Combined CSV:**
```csv
participant_id,session,item_1,item_2,item_3,item_4,item_5
1,baseline,5,4,5,4,5
1,followup,6,5,6,5,6
2,baseline,4,3,4,3,4
2,followup,5,4,5,4,5
```

**Processing Code:**
```r
# Data is already in long format!
data <- read.csv("combined_export.csv")
data <- prepare_qualtrics(data, remove_first_rows = 2)

# Calculate scores
data$scale_score <- rowMeans(data[, paste0("item_", 1:5)], na.rm = TRUE)

# Convert to wide for analysis
wide_data <- long_to_wide(
  data,
  id_cols = "participant_id",
  names_from = "session",
  values_from = "scale_score"
)

# Run paired t-test
result <- run_ttest(wide_data, design = "within", 
                   group1 = "baseline", group2 = "followup")
```

**Option B: Single Survey with Time Prefix**
```
Fields:
- participant_id
- t1_item_1, t1_item_2, ..., t1_item_10
- t2_item_1, t2_item_2, ..., t2_item_10
- t3_item_1, t3_item_2, ..., t3_item_10
```

**Exported CSV:**
```csv
participant_id,t1_item_1,t1_item_2,t1_item_3,t2_item_1,t2_item_2,t2_item_3,t3_item_1,t3_item_2,t3_item_3
1,5,4,5,6,5,6,6,6,7
2,4,3,4,5,4,5,5,5,6
```

**Processing Code:**
```r
# Data is in wide format
data <- read.csv("survey_export.csv")
data <- prepare_qualtrics(data, remove_first_rows = 2)

# Calculate scale scores for each time point
data$t1_score <- rowMeans(data[, paste0("t1_item_", 1:3)], na.rm = TRUE)
data$t2_score <- rowMeans(data[, paste0("t2_item_", 1:3)], na.rm = TRUE)
data$t3_score <- rowMeans(data[, paste0("t3_item_", 1:3)], na.rm = TRUE)

# Convert to long format
long_data <- wide_to_long(
  data[, c("participant_id", "t1_score", "t2_score", "t3_score")],
  id_cols = "participant_id",
  value_cols = c("t1_score", "t2_score", "t3_score"),
  names_to = "timepoint",
  values_to = "score"
)

# Run repeated measures ANOVA
result <- run_anova(
  long_data,
  design = "repeated_measures",
  dv = "score",
  subject_id = "participant_id",
  within_factor = "timepoint"
)
```

### Example 3: Mixed Design (Between + Within)

**Survey Structure:**
```
Fields:
- participant_id
- condition (control, treatment) [between factor]
- pre_item_1 through pre_item_10
- post_item_1 through post_item_10
```

**Exported CSV:**
```csv
participant_id,condition,pre_item_1,pre_item_2,post_item_1,post_item_2
1,control,5,4,6,5
2,control,4,3,5,4
3,treatment,5,5,7,6
4,treatment,4,4,6,6
```

**Processing Code:**
```r
data <- read.csv("survey_export.csv")
data <- prepare_qualtrics(data, remove_first_rows = 2)

# Calculate scores
data$pre_score <- rowMeans(data[, c("pre_item_1", "pre_item_2")], na.rm = TRUE)
data$post_score <- rowMeans(data[, c("post_item_1", "post_item_2")], na.rm = TRUE)

# Convert to long format for mixed ANOVA
long_data <- wide_to_long(
  data[, c("participant_id", "condition", "pre_score", "post_score")],
  id_cols = c("participant_id", "condition"),
  value_cols = c("pre_score", "post_score"),
  names_to = "time",
  values_to = "score"
)

# Run mixed ANOVA (between: condition, within: time)
# Note: For true mixed ANOVA, consider using additional packages like afex or ez
```

## Data Quality Checks

### Essential Fields to Export

1. **ResponseId**: Unique identifier for each response
2. **Progress**: Completion percentage
3. **Duration**: Time taken (in seconds)
4. **Finished**: Whether survey was completed
5. **RecordedDate**: When response was recorded

### Recommended Attention Checks

Include attention check items:
```
attention_check_1: "Please select 'Strongly Agree' for this item"
attention_check_2: "To show you are reading, choose option 4"
```

**Processing:**
```r
# Filter out poor quality responses
data_filtered <- data[
  data$Progress == 100 &
  data$Duration > 120 &  # At least 2 minutes
  data$Duration < 3600 &  # Less than 1 hour
  data$attention_check_1 == 5 &
  data$attention_check_2 == 4,
]
```

## Common Pitfalls to Avoid

### 1. Inconsistent Naming
❌ **Don't:**
```
Q1, Q2_1, question3, Item_4
```

✅ **Do:**
```
item_1, item_2, item_3, item_4
```

### 2. Mixed Scale Types
❌ **Don't:** Mix 1-5 and 1-7 scales in the same measure

✅ **Do:** Use consistent scales throughout

### 3. Unclear Reverse Coding
❌ **Don't:** Reverse code in your head during analysis

✅ **Do:** Mark reverse items clearly and code them properly:
```r
reverse_score(data, items = c("item_2_rev", "item_4_rev"), 
              min_value = 1, max_value = 7)
```

### 4. Too Many Open-Ended Questions
❌ **Don't:** Include excessive text responses that complicate export

✅ **Do:** Use scaled responses where possible; export text separately if needed

### 5. Missing Demographic Info
❌ **Don't:** Forget to collect age, condition, or other key variables

✅ **Do:** Include all variables needed for analysis upfront

## Summary Checklist

Before finalizing your survey:

- [ ] Question names are clear and consistent
- [ ] Reverse-coded items are clearly marked
- [ ] Response scales are consistent within measures
- [ ] All necessary demographic variables are included
- [ ] Experimental conditions are properly coded
- [ ] Attention checks are included
- [ ] Time/session identifiers are included (if repeated measures)
- [ ] Participant IDs are collected (if longitudinal)

Before exporting:

- [ ] Choose numeric values for scaled questions
- [ ] Include all relevant fields
- [ ] Document your export settings
- [ ] Note which items need reverse scoring

After importing to R:

- [ ] Remove Qualtrics header rows: `prepare_qualtrics(data, remove_first_rows = 2)`
- [ ] Reverse score appropriate items: `reverse_score()`
- [ ] Check data structure: `str(data)`
- [ ] Verify sample size: `nrow(data)`
- [ ] Check for missing data: `summary(data)`

## Additional Resources

For more complex designs or analysis needs, consider:
- Package documentation: `?longorwide`
- Vignettes: `vignette("introduction", package = "longorwide")`
- Code snippets: See CODE_SNIPPETS.md
- Interactive converter: `run_converter_app()`
