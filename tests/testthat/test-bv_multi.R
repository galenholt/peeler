# Varespec not lazy
require(vegan)
data(varespec)

test_that("restarts works", {
  # This uses furrr, but not parallel
  set.seed(17)
  # a <- .Random.seed
  bvout <- bv_multi(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                   rand_start = TRUE, nrand = 5, num_restarts = 5)
  expect_s3_class(bvout, 'data.frame')
  expect_equal(nrow(bvout), 76) #This will not be the same as purrr, since furrr seeds itself
  expect_equal(names(bvout), c('random_start', 'step', 'FB', 'corr', 'species'))


})

test_that("parallel works", {
  # Using this to test actual parallel and more runs to hit edge cases.
  set.seed(17)
  future::plan(future::multisession)
  bvout <- bv_multi(ref_mat = varespec, comp_mat = varespec,
                    ref_dist = 'bray', comp_dist = 'bray',
                    rand_start = TRUE, nrand = 5, num_restarts = 50)

  expect_type(bvout, 'tibble')
  expect_equal(names(bvout), c('random_start', 'step', 'FB', 'corr', 'species'))

  # reset future plan
  future::plan(future::sequential)

})

test_that("purrr works", {
  # Test the bypass if future not installed
  set.seed(17)
  # a <- .Random.seed
  local_mocked_bindings(is_installed = function(...) FALSE, .package = 'rlang')
    bvout <- bv_multi(ref_mat = varespec, comp_mat = varespec,
                      ref_dist = 'bray', comp_dist = 'bray',
                      rand_start = TRUE, nrand = 5, num_restarts = 5)

    expect_s3_class(bvout, 'data.frame')

    expect_equal(nrow(bvout), 80)

    expect_equal(names(bvout), c('random_start', 'step', 'FB', 'corr', 'species'))

})
