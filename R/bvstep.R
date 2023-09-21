#' Implements the bvstep algorithm from Clarke and Warwick
#'
#' If we start with `rand_start` and `nrand` is more than 1, this starts with backward steps. If there is only a single column start (e.g. `rand_start = FALSE`) or only `force_include`, starts with forward selection. Note that though there is only ever a single forward step before backward, backward steps do not get saved into the dataframe if they do not increase rho, and forward steps do not get entered if they increase rho by less than `min_delta_rho` (and the steps then terminate).
#'
#' @param ref_mat the reference ('fixed') matrix that gets considered in whole
#' @param comp_mat the 'variable' matrix that gets forward/backward chopped
#' @param ref_dist distance metric for `ref_mat` (see `method` in [vegan::vegdist()])
#' @param comp_dist distance metric for `comp_mat` (see `method` in [vegan::vegdist()])
#' @param rand_start logical, default `TRUE`.
#'  * `TRUE`, start with `nrand` randomly-selected columns from `comp_mat` (plus any in `force_include`). Useful with [bv_multi()] to avoid local optima.
#'  * `FALSE`, start with the best available single column of `comp_mat` if `force_include = NULL` or `force_include`.
#' @param nrand number of columns to choose for a random start. Defaults to 10%. Should not be too large, or it is hard to drop uninformative. Only used if `rand_start = TRUE`
#' @param fixed_start `NULL` (default) or character of columns to start with. Allows forcing starts with set subset of the data.
#' @param force_include `NULL` (default) or character of columns to always include- these are there at the start and never get dropped. If `rand_start = TRUE`, random columns are in addition to these.
#' @param force_exclude `NULL` (default) or character of columns to always exclude- these are just dropped right at the start.
#' @param rho_threshold Default 0.95. Threshold at which to cut off the process. If this is crossed at a forward step, one last backward step is taken to check if a smaller set still meets the condition.
#' @param min_delta_rho Default 0.001. Cutoff to stop the process if rho is not increasing much.
#' @param corr_method character, default `kendall`. This is the `method` argument of [cor()]. Clarke and Warwick 1998 suggests kendall because we need a rank correlation and spearman doesn't handle ties.
#' @param selection_ref character, `'name'` (default)- return the variable names in each step. `'index'` returns their column index in `comp_mat`
#'
#' @return a data frame (tibble) with the iteration, whether it was forward/backward, correlation, and set of column names selected.
#' @export
#'
#' @examples
#' require(vegan)
#' data(varespec)
#' bvout <- bvstep(ref_mat = varespec, comp_mat = varespec,
#' ref_dist = 'bray', comp_dist = 'bray',
#' rand_start = TRUE, nrand = 5)
bvstep <- function(ref_mat,
                   comp_mat,
                   ref_dist = 'bray',
                   comp_dist = 'bray',
                   rand_start = TRUE,
                   nrand = round(ncol(ref_mat)/10),
                   fixed_start = NULL,
                   force_include = NULL,
                   force_exclude = NULL,
                   rho_threshold = 0.95,
                   min_delta_rho = 0.001,
                   corr_method = 'kendall',
                   selection_ref = 'name') {

  # We need matrices, not data frames or other
  if (!inherits(ref_mat, "matrix")) {
    ref_mat <- as.matrix(ref_mat)
  }
  if (!inherits(comp_mat, "matrix")) {
    comp_mat <- as.matrix(comp_mat)
  }

  # If forcing exclusions, just clip comp_mat at the beginning
  if (!is.null(force_exclude)) {
    comp_mat <- comp_mat[ , which(!(colnames(comp_mat) %in% force_exclude)), drop = FALSE]
  }

  # flag to bypass random starts if not possible
  rand_bypass <- FALSE

  # get the reference distance matrix
  ref_dissim <- vegan::vegdist(ref_mat, method = ref_dist)

  # If no species are at multiple sites, everything falls over (distance matrices yield 1s and cor is NA)
  if (all(colSums(comp_mat > 0) == 1)) {
    rlang::abort("No species is at multiple sites. Distance matrices and correlations will collapse. Check your data")
  }

  # find the starting sample- either a random set or the best individual sample
  if (rand_start) {
    if (nrand <= ncol(comp_mat)) {

      # Force including and random starts will be additive- ie we choose some
      # random set on top of the forced
      if (!is.null(force_include) | !is.null(fixed_start)) {
        rlang::inform(glue::glue("Choosing {nrand} random species in addition to
                    {length(force_include)} forced inclusions and
                    {length(fixed_start)} fixed starting groups.
                    The initial set length may not be the sum if variables appear in more than
                      one of the groups "))
        fixed_start_set <- unique(c(force_include, fixed_start))

      }

      # Distance matrices and correlations will collapse if we happen to choose
      # a set with species that are only at one site. So if that's the case,
      # keep looking.
      no_multisite <- TRUE
      singlecounter <- 1
      while (no_multisite & (singlecounter <= min(100, ncol(comp_mat)))) {

        rand_start_set <- sample(colnames(comp_mat), nrand)
        start_set <- unique(c(force_include, fixed_start, rand_start_set))
        check_mat <- comp_mat[,start_set, drop = FALSE]
        no_multisite <- all(colSums(check_mat > 0) == 1)

        # helpful for debug.
        # if (no_multisite) {
        #   print(glue::glue("failed the {counter} time, trying again."))
        # }

        singlecounter <- singlecounter + 1
      }

      # if we still havent' picked something up purely randomly by the time we've hit the
      # counter cutoff, stuff in one we know works
      if (no_multisite) {
        multisitespecies <- which(colSums(comp_mat > 0) > 1)

        ringer <- sample(names(multisitespecies), 1)
        rand_start_set <- sample(colnames(comp_mat), nrand-1)

        start_set <- unique(c(force_include, fixed_start, rand_start_set, ringer))
        check_mat <- comp_mat[,start_set, drop = FALSE]
      }

      current_cor <- distcorr(comp_mat = check_mat, ref_distmat = ref_dissim,
                             comp_dist = comp_dist,
                             corr_method)

      if (is.na(current_cor)) {
        rlang::abort("correlation between starting set and the reference are NA. Likely due to sparse data.")
      }

      current_set <- colnames(check_mat)
      nextstep <- 'back'
    } else {
        rlang::warn(glue::glue("`comp_mat` has {ncol(comp_mat)} columns,
                             asking for a random selection of {nrand},
                             which is too many. Using all columns,
                             but this bypasses the advantage of the random
                             start to avoid local optima."))
      rand_bypass <- TRUE
      }
  }

  # If not a random set, start with best individual species or the force_include
  if ((!rand_start) | rand_bypass) {
    # If we are force_including, just start with those
    if (!is.null(force_include) | !is.null(fixed_start)) {
      check_mat <- comp_mat[,unique(c(force_include, fixed_start)), drop = FALSE]
      current_cor <- distcorr(comp_mat = check_mat, ref_distmat = ref_dissim,
                              comp_dist = comp_dist,
                              corr_method)
      current_set <- colnames(check_mat)
      nextstep <- 'forward'
    } else {
      # If not force_including or fixed_start, find the best single species and move up.
      # Clarke and Warwick call this the NULL case, but it boils down to starting with the best species and then moving forward

      check_cors <- apply(comp_mat, MARGIN = 2, FUN = distcorr,
                          ref_distmat = ref_dissim,
                          comp_dist = comp_dist,
                          corr_method)
      current_set <- names(check_cors)[which(check_cors == max(check_cors, na.rm = TRUE))]
      current_cor <- max(check_cors, na.rm = TRUE)
      check_mat <- comp_mat[ ,current_set, drop = FALSE]
      nextstep <- 'forward'
    }
  }

  # Set up to track steps. We don't know how long this will be, unfortunately, so we'll have to build rowwise.
  counter <- 1
  track_steps <- tibble::tibble(step = counter, FB = NA,
                                num_vars = length(current_set),
                                corr = current_cor, species = paste0(current_set, collapse = ', '))

  # To start, just call the first deltarho rho
  deltarho <- current_cor
  # set the final_back flag to FALSE- this gives the backstep one more chance
  # after forward crosses the rho_threshold
  final_back <- FALSE

  # Now we need the logic for continuing, and inside that, the forward/backward logic
  while (current_cor < rho_threshold & deltarho > min_delta_rho & !final_back) {

    # Do a forward step if we start with a single species, or if the backward selection has finished and set the nextstep flag to 'forward'
    if (length(current_set) == 1 | nextstep == 'forward') {
      steptype <- 'F'
      # A forward step
      new_cor <- forward_step(comp_mat, initial_sp = current_set,
                              ref_distmat = ref_dissim,
                              comp_dist = comp_dist,
                              corr_method)


      # sometimes we pick up two identical corrs. If that's the case, pick one at random
      if (length(new_cor) > 1) {
        new_cor <- sample(new_cor, 1)
      }


      new_set <- c(current_set, names(new_cor))

      # forward only ever happens once. It effectively happens twice when we start
      # with one species, but there's actually a hidden pointless backstep in
      # there, and keeping that lets us keep the loops much cleaner
      nextstep <- 'back'



      # only calculate deltarho here- we should only small-change break out on a forward step
      deltarho <- unname(new_cor) - unname(current_cor)

            # Annoying to have the counter iterator inside the if, but we need to not
      # step it or save the output of this loop if delta_rho is too small here
      if (deltarho > min_delta_rho) {
        # calculate change and set the rho tracking
        current_cor <- new_cor
        current_set <- new_set
        counter <- counter + 1
        track_steps <- dplyr::bind_rows(track_steps,
                                        tibble::tibble(step = counter, FB = steptype,
                                                       num_vars = length(new_set),
                                                       corr = new_cor,
                                                       species = paste0(new_set, collapse = ', ')))
      }

      # If we cross rho_threshold on a forward, allow a backstep the chance to
      # be better (as in Table 1)
      if (current_cor > rho_threshold) {
        final_back <- TRUE
      }

    }


    # step backwards if we've just stepped forward and set the nextstep flag to
    # 'back', but don't do a backstep if the last forward didn't improve rho
    # enough
    if (nextstep == 'back' & deltarho > min_delta_rho) {
      steptype <- 'B'
      # A backward step
      if (!is.null(force_include) && all(current_set %in% force_include)) {
        rlang::warn("all possible species are in `force_include`, cannot take a backward step on iteration {counter}. Moving back to forward")
        nextstep <- 'forward'
        break()
      }

      # limit the species to possibly remove if there's a force_include
      if (!is.null(force_include)) {
        rem_sp <- current_set[!(current_set %in% force_include)]
      } else {
        rem_sp <- current_set
      }

      # The name on here is the *removed* species
      new_cor <- backward_step(remove_sp = rem_sp, comp_mat = comp_mat,
                               initial_sp = current_set,
                              ref_distmat = ref_dissim,
                              comp_dist = comp_dist,
                              corr_method)


      # sometimes we pick up two identical corrs. If that's the case, pick one at random
      if (length(new_cor) > 1) {
        new_cor <- sample(new_cor, 1)
      }

      # I don't think this can happen, provided the previous step had at least one working corr, but an error catch here for the situation where all corrs are NA
      if (is.na(new_cor)) {
        rlang::abort(glue::glue("all correlations in backstep at counter {counter} are NA.
                                This is often due to having only unique species in each site,
                                but it's unclear how it would happen if step 1 worked."))
      }

      new_set <- current_set[!(current_set %in% names(new_cor))]

      # Don't call this deltarho, since we only want to quit the loop if forward
      # addition fails to improve- backward steps often will make things worse
      back_deltarho <- new_cor - current_cor

      # If all the removals make rho worse, go back to forward and leave
      # current_cor and current_set alone. I'm using 0 and not min_delta_rho
      # here, because we're looking for a minimal set. And so if removing a
      # species leaves rho within min_delta_rho, that's an improvement. We could
      # even make it -1*min_delta_rho for that reason, but I don't think that's
      # what Clarke and Warwick do. Don't reset anything (including the counter)
      # in this case- it means we end up with silent loop iterations, but I
      # think the output would get confusing (and PRIMER doesn't give the failed
      # backsteps)

      if (back_deltarho <= 0) {
        nextstep <- 'forward'
        # If we're on the final_back and it doesn't help, set it to false so the loop breaks
        if (final_back & (new_cor < rho_threshold)) {
          final_back <- FALSE
        }
      }

      if (back_deltarho > 0 | (final_back & (new_cor >= rho_threshold))) {
        nextstep <- 'back'
        current_cor <- new_cor
        current_set <- new_set
        counter <- counter + 1
        track_steps <- dplyr::bind_rows(track_steps,
                                        tibble::tibble(step = counter, FB = steptype,
                                                       num_vars = length(new_set),
                                                       corr = new_cor,
                                                       species = paste0(new_set, collapse = ', ')))
      }
    }
  }


  if (selection_ref == 'index') {

    track_steps <- track_steps |>
      dplyr::mutate(species = species_index(.data$species, comp_mat)) |>
      dplyr::mutate(species = purrr::map_chr(.data$species, \(x) sort(x)))
  } else if (selection_ref == 'name') {
    track_steps <- track_steps |>
      dplyr::mutate(species = purrr::map_chr(.data$species, \(x) paste0(sort(strsplit(x, ', ')[[1]]), collapse = ', ')))
  }
  return(track_steps)
}

species_index <- function(charsp, comp_mat) {
  numsp <- purrr::map_chr(charsp, \(x) paste0(as.character(which(colnames(comp_mat) %in% strsplit(x, ', ')[[1]])), collapse = ', '))
}


