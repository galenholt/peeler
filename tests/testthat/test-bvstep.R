# Varespec not lazy
library(vegan)
data(varespec)

test_that("varespec works", {
  set.seed(17)
  # a <- .Random.seed
  bvout <- bvstep(
    ref_mat = varespec, comp_mat = varespec,
    ref_dist = "bray", comp_dist = "bray",
    rand_start = TRUE, nrand = 5
  )
  expect_s3_class(bvout, "data.frame")
  expect_equal(nrow(bvout), 18)
  expect_equal(names(bvout), c("step", "FB", "num_vars", "corr", "species"))
  expect_true(count_test(bvout))
})

test_that("fixed_start works", {
  set.seed(17)
  # a <- .Random.seed
  bvout <- (bvstep(
    ref_mat = varespec, comp_mat = varespec,
    ref_dist = "bray", comp_dist = "bray",
    rand_start = FALSE,
    fixed_start = c("Polycomm", "Pohlnuta")
  ))
  expect_s3_class(bvout, "data.frame")
  expect_equal(bvout$species[1], "Pohlnuta, Polycomm")
  expect_equal(names(bvout), c("step", "FB", "num_vars", "corr", "species"))
  expect_true(count_test(bvout))
})

test_that("fixed_start with random works", {
  set.seed(17)
  # a <- .Random.seed
  bvout <- (bvstep(
    ref_mat = varespec, comp_mat = varespec,
    ref_dist = "bray", comp_dist = "bray",
    rand_start = TRUE, nrand = 5,
    fixed_start = c("Polycomm", "Pohlnuta")
  ))
  expect_s3_class(bvout, "data.frame")
  expect_equal(bvout$species[1], "Cladamau, Cladcris, Icmaeric, Peltapht, Pohlnuta, Polycomm, Stersp")
  expect_equal(names(bvout), c("step", "FB", "num_vars", "corr", "species"))
  expect_true(count_test(bvout))
})


test_that("best start works", {
  # should always be the same
  # set.seed(17)
  # a <- .Random.seed
  bvout <- (bvstep(
    ref_mat = varespec, comp_mat = varespec,
    ref_dist = "bray", comp_dist = "bray",
    rand_start = FALSE
  ))
  expect_s3_class(bvout, "data.frame")
  expect_equal(bvout$species[1], "Pleuschr")
  expect_equal(names(bvout), c("step", "FB", "num_vars", "corr", "species"))
  expect_true(count_test(bvout))
})
# Need to test a force_include with all species and see if it goes infinite

test_that("Ensure success with -Inf", {
  set.seed(17)
  # a <- .Random.seed
  # This never actually goes negative, need a different test dataset
  bvout <- bvstep(
    ref_mat = varespec, comp_mat = varespec,
    ref_dist = "bray", comp_dist = "bray",
    rand_start = TRUE, nrand = 5,
    rho_threshold = 1,
    min_delta_rho = -Inf
  )
  expect_s3_class(bvout, "data.frame")
  expect_equal(nrow(bvout), 49)
  expect_equal(max(bvout$corr, na.rm = TRUE), 1)
  expect_equal(names(bvout), c("step", "FB", "num_vars", "corr", "species"))
  expect_true(count_test(bvout))
})

test_that("Use up all species before reaching rho", {
  set.seed(17)
  # a <- .Random.seed
  # This never actually goes negative, need a different test dataset
  bvout <- bvstep(
    ref_mat = varespec,
    comp_mat = varespec[, sample(30)],
    ref_dist = "bray", comp_dist = "bray",
    rand_start = TRUE, nrand = 5,
    rho_threshold = 1,
    min_delta_rho = -Inf
  )
  expect_s3_class(bvout, "data.frame")
  expect_equal(nrow(bvout), 30)
  expect_equal(names(bvout), c("step", "FB", "num_vars", "corr", "species"))
  expect_true(count_test(bvout))
})
