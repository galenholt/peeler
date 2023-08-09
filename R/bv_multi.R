#' Wrapper for `bvstep` to restart over random starts to avoid finding only
#' local optima.
#'
#' Runs [bvstep()] a number of times with random starts, sorts the outcomes by
#' correlation, and returns the best `num_best_results` as either a list or
#' dataframe. This uses {furrr} if it is installed, and so allows the user to
#' run each set of randon starts in parallel by setting a `[future::plan()]`, e.g.
#' `plan(multisession)` before running this code.
#'
#'
#' @inheritParams bvstep
#'
#' @param num_restarts number of times run the bvstep from random starts
#' @param num_best_results how many of the outputs to return. Runs are sorted
#'   from highest to lowest correlation, and the top `num_best_results` are
#'   returned, with ties determined by `ties.method`
#' @param ties.method Argument passed to [base::rank()]: how to handle ties
#'   between runs when sorting by highest correlation. Default `random` just
#'   chooses tied runs at random, and so if ties cross the threshold of
#'   `num_best_results`, the output will have `num_best_results` runs in it, but
#'   there may be others with the same stopping correlation. The other logical
#'   choice is `min`, ties are given the minimum value. This will return *at
#'   least* `num_best_results` runs, but may return more if ties cross that
#'   boundary.
#' @param returndf logical, default `TRUE`-
#'  * `TRUE`: return a dataframe as in [bvstep()] with an additional column indicating which iterations are returned.
#'  * `FALSE`: return a list, with each element a dataframe as returned by [bvstep()]
#'
#' @return dataframe or list, as determined by `returndf`, of the best
#'   `num_best_results`, sorted by highest correlations.
#' @export
#'
#' @examples
bv_multi <- function(ref_mat,
                     comp_mat,
                     ref_dist = 'bray',
                     comp_dist = 'bray',
                     rand_start = TRUE,
                     nrand = round(ncol(ref_mat)/10),
                     num_restarts = ifelse(rand_start, 5, 1),
                     num_best_results = min(c(5, num_restarts)),
                     ties.method = 'random',
                     force_include = NULL,
                     force_exclude = NULL,
                     rho_threshold = 0.95,
                     min_delta_rho = 0.001,
                     corr_method = 'kendall',
                     returndf = TRUE,
                     selection_ref = 'name') {

  # Sanity check the num_restarts
  if (!rand_start & num_restarts > 1) {
    rlang::warn("no reason to restart if no random starts. setting num_restarts to 1")
    num_restarts <- 1
  }

  # and the num_best_results
  if (num_best_results > num_restarts) {
    rlang::warn(glue::glue("Asking for {num_best_results}, but only running {num_restarts} times. Returning all results"))
    num_best_results <- length(best_order)
  }

  # make a list of dataframes. allow parallelisation with furrr. Not sure it's worth it

  if (rlang::is_installed('furrr')) {
    bvlist <- furrr::future_map(1:num_restarts, \(i) bvstep(ref_mat = ref_mat,
                                                            comp_mat = comp_mat,
                                                            ref_dist = ref_dist,
                                                            comp_dist = comp_dist,
                                                            rand_start = rand_start,
                                                            nrand = nrand,
                                                            force_include = force_include,
                                                            force_exclude = force_exclude,
                                                            rho_threshold = rho_threshold,
                                                            min_delta_rho = min_delta_rho,
                                                            corr_method = corr_method,
                                                            selection_ref = selection_ref),
                                .options = furrr::furrr_options(seed = TRUE))
  } else {
    bvlist <- purrr::map(1:num_restarts, \(i) bvstep(ref_mat = ref_mat,
                                                     comp_mat = comp_mat,
                                                     ref_dist = ref_dist,
                                                     comp_dist = comp_dist,
                                                     rand_start = rand_start,
                                                     nrand = nrand,
                                                     force_include = force_include,
                                                     force_exclude = force_exclude,
                                                     rho_threshold = rho_threshold,
                                                     min_delta_rho = min_delta_rho,
                                                     corr_method = corr_method,
                                                     selection_ref = selection_ref))
  }

  names(bvlist) <- as.character(1:num_restarts)

  # Rank and sort them by maximum correlation
  maxcor <- sapply(bvlist, \(x) max(x$corr))

  # negative here to have larger numbers first
  best_order <- rank(-maxcor, ties.method = ties.method)

  # Truncate the list at the num_best_results

  best_order_trunc <- sort(best_order[best_order <= num_best_results])

  bvlist <- bvlist[names(best_order_trunc)]

  if (returndf) {
    return(dplyr::bind_rows(bvlist, .id = "random_start"))
  } else {
    return(bvlist)
  }

}


