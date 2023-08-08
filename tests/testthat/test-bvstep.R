test_that("varespec works", {
  # Varespec not lazy
  library(vegan)
  data(varespec)
  set.seed(17)

  a <- .Random.seed
  bvout <- (bvstep(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                   rand_start = TRUE, nrand = 5))
  bvout

})

# Need to test a force_include with all species and see if it goes infinite

