#' Get names as a character vector instead of a single string
#'
#' To match PRIMER, the names are included as a single string with comma
#' separation. For further use, though, we need to parse that back to a
#' character vector
#'
#'
#' @param bvout output list or dataframe of a bvstep
#' @param step step (numeric) to extract. Default 'last' uses `nrow(bvout)`.
#'
#' @return character vector
#' @export
#'
#' @examples
#' require(vegan)
#' data(varespec)
#' bvout <- bvstep(
#'   ref_mat = varespec, comp_mat = varespec,
#'   ref_dist = "bray", comp_dist = "bray",
#'   rand_start = TRUE, nrand = 5
#' )
#' best_set <- extract_names(bvout)
#'
extract_names <- function(bvout, step = "last") {
  # if not a dataframe, make it one
  if (!inherits(bvout, "data.frame")) {
    bvout <- dplyr::bind_rows(bvout, .id = "random_start")
  }

  if (step == "last") {
    step <- nrow(bvout)
  }

  spnames <- strsplit(dplyr::pull(bvout[step, "species"]), ", ")[[1]]
}
