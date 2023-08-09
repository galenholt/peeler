#' Iteratively run bv_multi, removing the best set of species at each step
#'
#'
#' @inheritParams bv_multi
#'
#' @param peel_stop when to stop peeling
#'  * 'all'- default, runs until there are no more species
#'  * numeric -1 to 1, assumes a correlation threshold, and stops peeling when the best set drops below that value.
#' @param nrand as in [bvstep()], but once the peels remove enough columns, this just becomes all the columns in the later peels
#'
#' @return a tibble
#' @export
#'
#' @examples
peel <- function(ref_mat,
                 comp_mat,
                 ref_dist = 'bray',
                 comp_dist = 'bray',
                 peel_stop = 'all',
                 rand_start = TRUE,
                 nrand = round(ncol(ref_mat)/10),
                 num_restarts = ifelse(rand_start, 5, 1),
                 ties.method = 'random',
                 force_include = NULL,
                 force_exclude = NULL,
                 rho_threshold = 0.95,
                 min_delta_rho = 0.001,
                 corr_method = 'kendall') {

  # deal with peel_stop
  stopper <- FALSE
  # peel the whole set
  if (peel_stop == 'all') {peel_stop <- Inf}
  if (is.infinite(peel_stop)) {stop_type <- 'all'}
  # A rho stop will be between 0 and 1
  if (peel_stop < 1 & peel_stop >= -1) {stop_type = 'rho'}
  # an iteration stop
  if (peel_stop >= 1 & !is.infinite(peel_stop)) {stop_type <- 'iteration'}



  # We have to do this with a for (or foreach would be nicer because we'd avoid
  # the initialization step but I don't want to add the dependency), not
  # furrr/purrr/apply

  # Get the first peel to initialise all the outputs
  bv_one <- bv_multi(ref_mat = ref_mat,
                     comp_mat = comp_mat,
                     ref_dist = ref_dist,
                     comp_dist = comp_dist,
                     rand_start = rand_start,
                     nrand = min(c(nrand, ncol(comp_mat))),
                     num_restarts = num_restarts,
                     num_best_results = 1,
                     ties.method = ties.method,
                     force_include = force_include,
                     force_exclude = force_exclude,
                     rho_threshold = rho_threshold,
                     min_delta_rho = min_delta_rho,
                     corr_method = corr_method,
                     return_type = 'final',
                     returndf = TRUE,
                     selection_ref = 'name')

  # The final result of the best peel, with a peel reference added
  peel_df <- bv_one |>
    dplyr::mutate(peel = 1) |>
    dplyr::select(peel, dplyr::everything(), -random_start)

  # The names in the best peel to remove
  prev_peel_names <- unique(c(force_exclude, extract_names(bv_one)))

  # Start counter at 2 because we just did 1.
  counter <- 2
  # Now keep peeling and removing species
  while ((length(prev_peel_names) <= length(colnames(comp_mat))) & !stopper) {
    bv_one <- bv_multi(ref_mat = ref_mat,
                       comp_mat = comp_mat,
                       ref_dist = ref_dist,
                       comp_dist = comp_dist,
                       rand_start = rand_start,
                       nrand = min(c(nrand, ncol(comp_mat)-length(prev_peel_names))),
                       num_restarts = num_restarts,
                       num_best_results = 1,
                       ties.method = ties.method,
                       force_include = force_include,
                       force_exclude = prev_peel_names,
                       rho_threshold = rho_threshold,
                       min_delta_rho = min_delta_rho,
                       corr_method = corr_method,
                       return_type = 'final',
                       returndf = TRUE,
                       selection_ref = 'name')

    final_one <- bv_one |>
      dplyr::mutate(peel = counter) |>
      dplyr::select(peel, dplyr::everything(), -random_start)

    peel_df <- dplyr::bind_rows(peel_df, final_one)

    prev_peel_names <- c(prev_peel_names, extract_names(bv_one))

    if (stop_type == 'all' &
        (length(prev_peel_names) == length(colnames(comp_mat)))) {
      stopper <- TRUE
    }
    if (stop_type == 'rho' & final_one$corr <= peel_stop) {stopper <- TRUE}
    if (stop_type == 'iteration' & counter == peel_stop) {stopper <- TRUE}

    counter <- counter + 1

  }

  return(peel_df)

}
