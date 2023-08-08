#' Find the community distance for a variable community matrix and then the rank
#' correlation with a reference dissimilarity matrix
#'
#' @param comp_mat variable community matrix
#' @param ref_distmat reference dissimilarity matrix
#' @param comp_dist `method` argument to use in [vegan::vegdist()] for dissimilarity
#' @param corr_method `method` argument to use in [base::cor()] for correlation
#'
#' @return correlation value
#' @export
#'
#' @examples
distcorr <- function(comp_mat, ref_distmat, comp_dist, corr_method) {
  # This often throws warnings about empty rows, NaN, especially for single
  # species. Should catch those, package them up, and return somethign more
  # useful to the user
  suppressWarnings(comp_distmat <- vegan::vegdist(comp_mat, method = comp_dist))
  # Kendall as per Clarke and Warwick 1998
  # use = na.or.complete to get values when there are NaN in the matrices, as
  # there often are especialy for single species.
  correlation <- cor(ref_distmat, comp_distmat,
                     method = corr_method, use = 'na.or.complete')
  return(correlation)
}
