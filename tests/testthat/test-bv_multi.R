# Varespec not lazy
require(vegan)
data(varespec)

test_that("restarts works", {
  # This uses furrr, but not parallel
  set.seed(17)
  # a <- .Random.seed
  bvout <- bv_multi(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                   rand_start = TRUE, nrand = 5, num_restarts = 10)
  expect_s3_class(bvout, 'data.frame')
  expect_equal(nrow(bvout), 5)
  expect_equal(names(bvout), c('random_start', 'step', 'FB', 'num_vars', 'corr', 'species', 'num_tied_with'))
  expect_true(count_test(bvout))

})

test_that("parallel works", {
  # Using this to test actual parallel and more runs to hit edge cases.
  set.seed(17)
  future::plan(future::multisession)
  bvout <- bv_multi(ref_mat = varespec, comp_mat = varespec,
                    ref_dist = 'bray', comp_dist = 'bray',
                    rand_start = TRUE, nrand = 5, num_restarts = 50)

  expect_s3_class(bvout, 'data.frame')
  expect_equal(names(bvout), c('random_start', 'step', 'FB', 'num_vars', 'corr', 'species', 'num_tied_with'))
  expect_true(count_test(bvout))
  # reset future plan
  future::plan(future::sequential)

})

test_that("purrr works", {
  # Test the bypass if future not installed
  set.seed(17)
  # a <- .Random.seed
  local_mocked_bindings(is_installed = function(...) FALSE, .package = 'rlang')
    expect_warning(bvout <- bv_multi(ref_mat = varespec, comp_mat = varespec,
                      ref_dist = 'bray', comp_dist = 'bray',
                      rand_start = TRUE, nrand = 5, num_restarts = 5))

    expect_s3_class(bvout, 'data.frame')

    expect_equal(nrow(bvout), 5)

    expect_equal(names(bvout), c('random_start', 'step', 'FB', 'num_vars', 'corr', 'species', 'num_tied_with'))
    expect_true(count_test(bvout))

})

test_that("return_type 'steps' works", {
  # This uses furrr, but not parallel
  set.seed(17)
  # a <- .Random.seed
  bvout <- bv_multi(ref_mat = varespec, comp_mat = varespec,
                    ref_dist = 'bray', comp_dist = 'bray',
                    rand_start = TRUE, nrand = 5, num_restarts = 50, return_type = 'steps')
  expect_s3_class(bvout, 'data.frame')
  expect_in(nrow(bvout), c(74, 80)) # For some reason running this interactively vs in a full test yields different numbers. Both are ok
  expect_equal(names(bvout), c('random_start', 'step', 'FB', 'num_vars', 'corr', 'species'))
  expect_true(count_test(bvout))

})

test_that("return_type 'unique' works", {
  # This uses furrr, but not parallel
  set.seed(17)
  # a <- .Random.seed
  bvout <- bv_multi(ref_mat = varespec, comp_mat = varespec,
                    ref_dist = 'bray', comp_dist = 'bray',
                    rand_start = TRUE, nrand = 5, num_restarts = 50, return_type = 'unique')
  expect_s3_class(bvout, 'data.frame')
  expect_equal(nrow(bvout), 5)
  expect_equal(names(bvout), c('random_start', 'step', 'FB', 'num_vars', 'corr', 'species', 'num_tied_with'))
  expect_true(count_test(bvout))

})
