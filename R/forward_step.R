#' A single forward step
#'
#' Cycles through each possible variable to add and finds the best single
#' variable to add to the `comp_mat`, as determined by increase in rho.
#'
#' @inheritParams distcorr
#' @param initial_sp set of variables already included
#'
#' @return named number, with the name of the best variable to add and the
#'   correlation value with it included.
#' @export
#'
#' @examples
forward_step <- function(comp_mat, initial_sp, ref_distmat, comp_dist, corr_method) {
  names_to_loop <- colnames(comp_mat)[!(colnames(comp_mat) %in% initial_sp)]

  all_cors <- sapply(names_to_loop,
                     FUN = \(x) single_forward(x, comp_mat, initial_sp, ref_distmat, comp_dist, corr_method))

  best_cor <- all_cors[which(all_cors == max(abs(all_cors)))]

  return(best_cor)


}


#' Forward step for a single variable
#'
#' This is run for each possible addition in turn.
#'
#' @inheritParams forward_step
#' @param add_sp single variable to add
#'
#' @return
#' @export
#'
#' @examples
single_forward <- function(add_sp, comp_mat, initial_sp, ref_distmat, comp_dist, corr_method) {
  check_mat <- comp_mat[,c(initial_sp, add_sp), drop = FALSE]
  correlation <- distcorr(check_mat, ref_distmat, comp_dist, corr_method)
  return(correlation)
}
