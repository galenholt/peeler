# Varespec not lazy
library(vegan)
data(varespec)

test_that("quick check", {
  set.seed(17)
  peels <- peel(ref_mat = varespec,
                comp_mat = varespec,
                nrand = 6,
                num_restarts = 10,
                corr_method = 'spearman')

  expect_s3_class(peels, 'data.frame')
  expect_equal(nrow(peels), 7)
  expect_equal(names(peels), c('peel', 'step', 'FB', 'num_vars', 'corr', 'species', 'num_tied_with'))
})
