#' Wrapper for `bvstep` to restart over random starts to avoid finding only
#' local optima.
#'
#' Runs [bvstep()] a number of times with random starts, sorts the outcomes by
#' correlation, and returns the best `num_best_results` as either a list or
#' dataframe. This uses {furrr} if it is installed, and so allows the user to
#' run each set of randon starts in parallel by setting a `[future::plan()]`,
#' e.g. `plan(multisession)` before running this code.
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
#' @param return_type character, defines how much to return
#'  * `'final'`: default, returns the final outcome of the best `num_best_results` random starts
#'  * `'steps'`: returns the full set of forward/backward steps for the best `num_best_results` random starts
#'  * `'unique'`: returns the best `num_best_results` best selections out of all steps of all random starts. The first entry should be the same as in `'final'`, but after that they may not be, if the penultimate selection in some sets are better than the final selection in others
#' @param returndf logical, default `TRUE`, only relevant if `return_type =
#'   'steps`
#'  * `TRUE`: return a dataframe as in [bvstep()] with an additional column indicating which iterations are returned.
#'  * `FALSE`: return a list, with each element a dataframe as returned by [bvstep()]
#' @return dataframe (typically) or list (if `return_type == 'steps'` and
#'   `returndf = FALSE`), of the best `num_best_results`, sorted by number of
#'   species if correlation is over `rho_threshold`, and then highest
#'   correlations. The `num_tied_with` column indicates how many results had the
#'   same num_vars and correlation
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
                     return_type = 'final',
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

  # Fix to choose smallest set given above threshold
  # AND- choose the LAST, nto the MAX, since it could have stepped back
  # AND IN BVSTEP ITSELF
  # And should I return the best *unique*, which might return earlier examples?
  names(bvlist) <- as.character(1:num_restarts)

  # Get the final result from each iteration (usually)
  # These come in sorted
  if (return_type %in% c('final', 'steps')) {
    to_rank <- extract_final(bvlist)
  }

  # This version looks for the best x results across all steps, even if they're
  # not the final outcome. The top rank here should match the above version
  # (best outcome of best run), but the later ones may not

  # Limiting this to just above rho_threshold, or if none are, the single best.
  # This could be an issue for late peels, but otherwise it's a pain to do
  # conditional sorts
  if (return_type %in% c('unique')) {
    to_rank <- dplyr::bind_rows(bvlist, .id = "random_start")

    if (max(to_rank$corr, na.rm = TRUE) >= rho_threshold) {
      to_rank <- to_rank |>
        dplyr::filter(corr > rho_threshold)
    } else {
      to_rank <- to_rank|>
        dplyr::filter(corr == max(corr, na.rm = TRUE))
    }
  }



  # to handle ties, get the rank groups. This is a bit goofy because we want to
  # rank by number species and then correlation above the threshold, but
  # correlation and then species below it
  to_rank_above <- to_rank |>
    dplyr::mutate(above_thresh = corr >= rho_threshold) |>
    dplyr::filter(above_thresh)

  to_rank_below <- to_rank |>
    dplyr::mutate(above_thresh = corr >= rho_threshold) |>
    dplyr::filter(!above_thresh)

  ranked_best <- to_rank_above |>
    dplyr::group_by(num_vars, dc = dplyr::desc(corr)) |>
    dplyr::mutate(rankgroup = dplyr::cur_group_id(),
                  num_tied_with = dplyr::n()) |>
    dplyr::ungroup()  |>
    dplyr::mutate(tiebreak = stats::runif(n = length(species))) |>
    dplyr::arrange(num_vars, desc(corr), tiebreak) |>
    dplyr::select(-tiebreak, -above_thresh)

  # Start counting ranks at max group of those above the threshold, but if there aren't any, start at 1
  if (nrow(ranked_best) > 0) {
    rankstart <- max(ranked_best$rankgroup)
  } else {
    rankstart <- 1
  }

  # Rank those below the threshold by correlation and then number of species.
  ranked_below <- to_rank_below |>
    dplyr::group_by(dc = dplyr::desc(corr), num_vars) |>
    dplyr::mutate(rankgroup = rankstart + dplyr::cur_group_id(),
                  num_tied_with = dplyr::n()) |>
    dplyr::ungroup()  |>
    dplyr::mutate(tiebreak = stats::runif(n = length(species))) |>
    dplyr::arrange(desc(corr), num_vars,tiebreak) |>
    dplyr::select(-tiebreak, -above_thresh)

  ranked_best <- dplyr::bind_rows(ranked_best, ranked_below)

 # use `rank` to get the row indices with ties.method
  best_order <- which(rank(ranked_best$rankgroup,
                           ties.method = ties.method) <= num_best_results)

  best_set <- ranked_best[best_order, ] |>
    dplyr::select(-dc, -rankgroup)

  if (return_type == 'steps') {
    bvlist <- bvlist[best_set$random_start]
    if (returndf) {
      return(dplyr::bind_rows(bvlist, .id = "random_start"))
    } else {
      return(bvlist)
    }
  }

  if (return_type %in% c('final', 'unique')) {
    return(best_set)
  }




}


