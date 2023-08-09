#' Extract the final set from a dataframe or list of bvstep outputs
#'
#' @param bvout bvstep outputs, either dataframe or list
#'
#' @return dataframe
#' @export
#'
#' @examples
extract_final <- function(bvout) {
  # if not a dataframe, make it one
  if (!inherits(bvout, 'data.frame')) {
    bvout <- dplyr::bind_rows(bvout, .id = "random_start")
  }

  # The `tiebreak` column prevents the
  # result from defaulting to alphabetically sorting ties
  bv_final <- bvout |>
    dplyr::group_by(random_start) |>
    dplyr::summarise(across(everything(), dplyr::last)) |>
    dplyr::ungroup() |>
    dplyr::mutate(species = stringr::str_sort(species)) |>
    dplyr::mutate(tiebreak = stats::runif(n = length(species))) |>
    dplyr::arrange(num_vars, desc(corr), tiebreak) |>
    dplyr::select(-tiebreak)

  return(bv_final)
}
