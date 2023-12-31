% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/peel.R
\name{peel}
\alias{peel}
\title{Iteratively run bv_multi, removing the best set of species at each step}
\usage{
peel(
  ref_mat,
  comp_mat,
  ref_dist = "bray",
  comp_dist = "bray",
  peel_stop = "all",
  rand_start = TRUE,
  nrand = max(1, round(ncol(ref_mat)/10)),
  num_restarts = ifelse(rand_start, 5, 1),
  ties.method = "random",
  force_include = NULL,
  force_exclude = NULL,
  rho_threshold = 0.95,
  min_delta_rho = 0.001,
  corr_method = "kendall",
  parallel = TRUE
)
}
\arguments{
\item{ref_mat}{the reference ('fixed') matrix that gets considered in whole}

\item{comp_mat}{the 'variable' matrix that gets forward/backward chopped}

\item{ref_dist}{distance metric for \code{ref_mat} (see \code{method} in \code{\link[vegan:vegdist]{vegan::vegdist()}})}

\item{comp_dist}{distance metric for \code{comp_mat} (see \code{method} in \code{\link[vegan:vegdist]{vegan::vegdist()}})}

\item{peel_stop}{when to stop peeling
\itemize{
\item 'all'- default, runs until there are no more species
\item numeric -1 to 1, assumes a correlation threshold, and stops peeling when the best set drops below that value.
}}

\item{rand_start}{logical, default \code{TRUE}.
\itemize{
\item \code{TRUE}, start with \code{nrand} randomly-selected columns from \code{comp_mat} (plus any in \code{force_include}). Useful with \code{\link[=bv_multi]{bv_multi()}} to avoid local optima.
\item \code{FALSE}, start with the best available single column of \code{comp_mat} if \code{force_include = NULL} or \code{force_include}.
}}

\item{nrand}{as in \code{\link[=bvstep]{bvstep()}}, but once the peels remove enough columns, this just becomes all the columns in the later peels}

\item{num_restarts}{number of times run the bvstep from random starts}

\item{ties.method}{Argument passed to \code{\link[base:rank]{base::rank()}}: how to handle ties
between runs when sorting by highest correlation. Default \code{random} just
chooses tied runs at random, and so if ties cross the threshold of
\code{num_best_results}, the output will have \code{num_best_results} runs in it, but
there may be others with the same stopping correlation. The other logical
choice is \code{min}, ties are given the minimum value. This will return \emph{at
least} \code{num_best_results} runs, but may return more if ties cross that
boundary.}

\item{force_include}{\code{NULL} (default) or character of columns to always include- these are there at the start and never get dropped. If \code{rand_start = TRUE}, random columns are in addition to these.}

\item{force_exclude}{\code{NULL} (default) or character of columns to always exclude- these are just dropped right at the start.}

\item{rho_threshold}{Default 0.95. Threshold at which to cut off the process. If this is crossed at a forward step, one last backward step is taken to check if a smaller set still meets the condition.}

\item{min_delta_rho}{Default 0.001. Cutoff to stop the process if rho is not increasing much.
\itemize{
\item Use \code{-Inf} If you want to ensure the algorithm finds something greater than rho_threshold (or as high as possible if rho_threshold is never met), even if it means using all the data. Any negative value allows strings of worsening results followed by increases to get out of local minima
}}

\item{corr_method}{character, default \code{kendall}. This is the \code{method} argument of \code{\link[=cor]{cor()}}. Clarke and Warwick 1998 suggests kendall because we need a rank correlation and spearman doesn't handle ties.}

\item{parallel}{logical, default TRUE. Parallelise over num_restarts using \code{\link[furrr:future_map]{furrr::future_map()}}. Need to have {furrr} installed and have set a \code{\link[future:plan]{future::plan()}}. See the help for {furrr} or {future}.}
}
\value{
a tibble
}
\description{
Iteratively run bv_multi, removing the best set of species at each step
}
\examples{
require(vegan)
data(varespec)
peels <- peel(
  ref_mat = varespec,
  comp_mat = varespec,
  nrand = 6,
  num_restarts = 10,
  corr_method = "spearman"
)
}
