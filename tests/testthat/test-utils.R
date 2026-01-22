test_that("cronbach_alpha calculates correctly", {
  set.seed(123)
  data <- data.frame(
    item1 = sample(1:5, 20, replace = TRUE),
    item2 = sample(1:5, 20, replace = TRUE),
    item3 = sample(1:5, 20, replace = TRUE),
    item4 = sample(1:5, 20, replace = TRUE)
  )
  
  result <- cronbach_alpha(data, items = c("item1", "item2", "item3", "item4"))
  
  expect_true("alpha" %in% names(result))
  expect_true("standardized_alpha" %in% names(result))
  expect_true(is.numeric(result$alpha))
  expect_true(result$n_items == 4)
})

test_that("descriptive_stats works correctly", {
  data <- data.frame(
    var1 = c(10, 12, 14, 16, 18),
    var2 = c(5, 7, 9, 11, 13)
  )
  
  result <- descriptive_stats(data, vars = c("var1", "var2"))
  
  expect_equal(nrow(result), 2)
  expect_true("mean" %in% names(result))
  expect_true("sd" %in% names(result))
  expect_equal(result$mean[1], 14)
})

test_that("descriptive_stats works with groups", {
  data <- data.frame(
    group = rep(c("A", "B"), each = 5),
    var1 = c(10, 12, 14, 16, 18, 20, 22, 24, 26, 28)
  )
  
  result <- descriptive_stats(data, vars = "var1", group = "group")
  
  expect_equal(nrow(result), 2)
  expect_true("group" %in% names(result))
})

test_that("check_assumptions runs without error", {
  set.seed(123)
  data <- data.frame(
    group = rep(c("A", "B", "C"), each = 20),
    score = c(rnorm(20, 10, 2), rnorm(20, 12, 2), rnorm(20, 14, 2))
  )
  
  result <- check_assumptions(data, dv = "score", group = "group")
  
  expect_true("normality_by_group" %in% names(result))
  expect_true("homogeneity" %in% names(result))
})
