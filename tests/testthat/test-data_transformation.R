test_that("wide_to_long converts data correctly", {
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
  
  expect_equal(nrow(long_data), 9)
  expect_equal(ncol(long_data), 3)
  expect_true("timepoint" %in% names(long_data))
  expect_true("score" %in% names(long_data))
})

test_that("long_to_wide converts data correctly", {
  long_data <- data.frame(
    id = rep(1:3, each = 3),
    timepoint = rep(c("time1", "time2", "time3"), 3),
    score = c(10, 15, 20, 12, 14, 19, 11, 16, 21)
  )
  
  wide_data <- long_to_wide(
    long_data,
    id_cols = "id",
    names_from = "timepoint",
    values_from = "score"
  )
  
  expect_equal(nrow(wide_data), 3)
  expect_equal(ncol(wide_data), 4)
  expect_true("time1" %in% names(wide_data))
  expect_true("time2" %in% names(wide_data))
  expect_true("time3" %in% names(wide_data))
})

test_that("wide_to_long handles errors properly", {
  wide_data <- data.frame(
    id = 1:3,
    value1 = c(10, 12, 11)
  )
  
  expect_error(
    wide_to_long(wide_data, id_cols = "nonexistent", value_cols = "value1"),
    "Some id_cols not found"
  )
  
  expect_error(
    wide_to_long(wide_data, id_cols = "id", value_cols = "nonexistent"),
    "Some value_cols not found"
  )
})
