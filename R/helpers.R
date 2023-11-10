#' Let glue handle NULL and return 'NULL'
#' from https://github.com/tidyverse/glue/issues/100
#'
#' @param str string to return for NULL
#'
#' @return string for glue where there are NULLs
null_transformer <- function(str = "NULL") {
  function(text, envir) {
    out <- glue::identity_transformer(text, envir)
    if (is.null(out)) {
      return(str)
    }

    out
  }
}
