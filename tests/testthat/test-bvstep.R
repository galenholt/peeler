# Varespec not lazy
library(vegan)
data(varespec)

test_that("varespec works", {

  set.seed(17)
  # a <- .Random.seed
  bvout <- bvstep(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                   rand_start = TRUE, nrand = 5)
  expect_s3_class(bvout, 'data.frame')
  expect_equal(nrow(bvout), 17)
  expect_equal(names(bvout), c('step', 'FB', 'num_vars', 'corr', 'species'))

})

test_that("fixed_start works", {

  set.seed(17)
  # a <- .Random.seed
  bvout <- (bvstep(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                   rand_start = FALSE,
                   fixed_start = c("Polycomm", "Pohlnuta")))
  expect_s3_class(bvout, 'data.frame')
  expect_equal(bvout$species[1], "Pohlnuta, Polycomm")
  expect_equal(names(bvout), c('step', 'FB', 'num_vars', 'corr', 'species'))

})

test_that("fixed_start with random works", {

  set.seed(17)
  # a <- .Random.seed
  bvout <- (bvstep(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                   rand_start = TRUE, nrand = 5,
                   fixed_start = c("Polycomm", "Pohlnuta")))
  expect_s3_class(bvout, 'data.frame')
  expect_equal(bvout$species[1], "Cladamau, Cladcris, Icmaeric, Peltapht, Pohlnuta, Polycomm, Stersp")
  expect_equal(names(bvout), c('step', 'FB', 'num_vars', 'corr', 'species'))

})


test_that("best start works", {

  # should always be the same
  # set.seed(17)
  # a <- .Random.seed
  bvout <- (bvstep(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                   rand_start = FALSE))
  expect_s3_class(bvout, 'data.frame')
  expect_equal(bvout$species[1], "Pleuschr")
  expect_equal(names(bvout), c('step', 'FB', 'num_vars', 'corr', 'species'))

})
# Need to test a force_include with all species and see if it goes infinite

