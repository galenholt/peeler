count_sp <- function(x) {
  purrr::map_int(stringr::str_split(x, ', '), length)
}

count_test <- function(df) {
  df <- df |>
    dplyr::mutate(spnum = count_sp(species))

  all(df$num_vars == df$spnum)
}
