test_that("run_ttest works for between-subjects design", {
  set.seed(123)
  data <- data.frame(
    group = rep(c("A", "B"), each = 10),
    score = c(rnorm(10, 10, 2), rnorm(10, 12, 2))
  )
  
  result <- run_ttest(data, design = "between", dv = "score", iv = "group")
  
  expect_true("result" %in% names(result))
  expect_true("descriptives" %in% names(result))
  expect_s3_class(result$result, "htest")
})

test_that("run_ttest works for within-subjects design", {
  set.seed(123)
  data <- data.frame(
    pre = rnorm(10, 10, 2),
    post = rnorm(10, 12, 2)
  )
  
  result <- run_ttest(data, design = "within", group1 = "pre", group2 = "post")
  
  expect_true("result" %in% names(result))
  expect_true("descriptives" %in% names(result))
  expect_s3_class(result$result, "htest")
})

test_that("run_ttest works for multiple trials", {
  set.seed(123)
  data <- data.frame(
    trial1 = rnorm(10, 10, 2),
    trial2 = rnorm(10, 11, 2),
    trial3 = rnorm(10, 12, 2)
  )
  
  result <- run_ttest(
    data,
    design = "multiple_trials",
    trial_cols = c("trial1", "trial2", "trial3")
  )
  
  expect_true("results" %in% names(result))
  expect_true("descriptives" %in% names(result))
  expect_equal(nrow(result$descriptives), 3)
})
