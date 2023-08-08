#' A single backwards step
#'
#' Cycles through each possible variable to remove and finds the best single
#' variable to remove from the `comp_mat`, as determined by increase in rho.
#'
#' @inheritParams distcorr
#' @param initial_sp set of variables already included
#' @param remove_sp set of variables to possibly exclude. Typically same as
#'   `initial_sp`, unless `force_include` prohibits exclusion of some species
#'
#' @return named number, with the name of the best variable to remove and the
#'   correlation value with it removed.
#' @export
#'
#' @examples
backward_step <- function(remove_sp, comp_mat, initial_sp, ref_distmat, comp_dist, corr_method) {

  # in a backwards step, we cut each of the initial species in turn
  all_cors <- sapply(remove_sp,
                     FUN = \(x) single_backward(x, comp_mat, initial_sp, ref_distmat, comp_dist, corr_method))

  # not max(abs(cors)) because we don't want the strongest relationship, we want
  # the closest resemblance to the full community, and so only want (+)
  best_cor <- all_cors[which(all_cors == max(all_cors))]

  return(best_cor)


}


#' Backward step for a single variable
#'
#' This is run for each possible removal in turn.
#'
#' @inheritParams backward_step
#' @param cut_sp single variable to remove
#'
#' @return
#' @export
#'
#' @examples
single_backward <- function(cut_sp, comp_mat, initial_sp, ref_distmat, comp_dist, corr_method) {

  check_mat <- comp_mat[,initial_sp[!(initial_sp %in% cut_sp)]]
  correlation <- distcorr(check_mat, ref_distmat, comp_dist, corr_method)
  return(correlation)
}