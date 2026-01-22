test_that("reverse_score works correctly", {
  data <- data.frame(
    id = 1:3,
    item1 = c(5, 4, 3),
    item2 = c(2, 3, 4)
  )
  
  result <- reverse_score(data, items = "item2", min_value = 1, max_value = 5)
  
  expect_equal(result$item2, c(4, 3, 2))
  expect_equal(result$item1, c(5, 4, 3))  # Unchanged
})

test_that("reverse_score handles multiple items", {
  data <- data.frame(
    id = 1:3,
    item1 = c(5, 4, 3),
    item2 = c(2, 3, 4),
    item3 = c(1, 2, 5)
  )
  
  result <- reverse_score(
    data,
    items = c("item2", "item3"),
    min_value = 1,
    max_value = 5
  )
  
  expect_equal(result$item2, c(4, 3, 2))
  expect_equal(result$item3, c(5, 4, 1))
  expect_equal(result$item1, c(5, 4, 3))  # Unchanged
})

test_that("prepare_qualtrics removes header rows", {
  qualtrics_data <- data.frame(
    Q1 = c("ImportId", "Question", "1", "2"),
    Q2 = c("ImportId", "Question", "3", "4"),
    stringsAsFactors = FALSE
  )
  
  result <- prepare_qualtrics(qualtrics_data, remove_first_rows = 2)
  
  expect_equal(nrow(result), 2)
  expect_equal(result$Q1, c(1, 2))
})
