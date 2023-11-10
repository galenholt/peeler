
<!-- README.md is generated from README.Rmd. Please edit that file -->

# peeler

<!-- badges: start -->

[![R-CMD-check](https://github.com/galenholt/peeler/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/galenholt/peeler/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/galenholt/peeler/branch/master/graph/badge.svg)](https://app.codecov.io/gh/galenholt/peeler?branch=master)
<!-- badges: end -->

Peeler implements the bvstep algorithm from Clarke and Warwick 1998 and
uses it to ‘peel’ a dataset to find structural redundancy. It also
provides a way to randomly start bvstep many times to assess consistency
and avoid local optima.

## Installation

You can install the development version of peeler from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("galenholt/peeler")
```

## Example

``` r
library(peeler)
library(vegan)
#> Loading required package: permute
#> Loading required package: lattice
#> This is vegan 2.6-4
data(varespec)
```

You can use `bvstep` alone for a single realisation.

``` r
bvout <- bvstep(
  ref_mat = varespec, comp_mat = varespec,
  ref_dist = "bray", comp_dist = "bray",
  rand_start = TRUE, nrand = 5
)

bvout
#> # A tibble: 10 × 5
#>     step FB    num_vars  corr species                                           
#>    <dbl> <chr>    <int> <dbl> <chr>                                             
#>  1     1 <NA>         5 0.532 Cladarbu, Cladcerv, Cladunci, Pleuschr, Rhodtome  
#>  2     2 B            4 0.532 Cladarbu, Cladunci, Pleuschr, Rhodtome            
#>  3     3 F            5 0.677 Cladarbu, Cladstel, Cladunci, Pleuschr, Rhodtome  
#>  4     4 F            6 0.771 Cladarbu, Cladrang, Cladstel, Cladunci, Pleuschr,…
#>  5     5 F            7 0.838 Cladarbu, Cladrang, Cladstel, Cladunci, Pleuschr,…
#>  6     6 F            8 0.868 Cladarbu, Cladrang, Cladstel, Cladunci, Empenigr,…
#>  7     7 F            9 0.896 Cladarbu, Cladrang, Cladstel, Cladunci, Dicrfusc,…
#>  8     8 F           10 0.916 Cladarbu, Cladrang, Cladstel, Cladunci, Dicrfusc,…
#>  9     9 F           11 0.935 Cladarbu, Cladrang, Cladstel, Cladunci, Dicrfusc,…
#> 10    10 F           12 0.951 Callvulg, Cladarbu, Cladrang, Cladstel, Cladunci,…
```

While it is always possible to get a correlation of 1 when `ref_mat` and
`comp_mat` are the same, it is sometimes the case that local optima will
cause the algorithm to cut off before `rho_threshold` is reached. If you
want to *always* get at least one result, use a negative `min_delta_rho`
(ideally `min_delta_rho = -Inf`). We force it to happen here by setting
rho to 1.

``` r
bvout_force <- bvstep(
  ref_mat = varespec, comp_mat = varespec,
  ref_dist = "bray", comp_dist = "bray",
  rand_start = TRUE, nrand = 5,
  rho_threshold = 1,
  min_delta_rho = -Inf
)

bvout_force
#> # A tibble: 45 × 5
#>     step FB    num_vars  corr species                                           
#>    <dbl> <chr>    <int> <dbl> <chr>                                             
#>  1     1 <NA>         5 0.415 Cladgrac, Cladphyl, Cladrang, Dicrfusc, Polycomm  
#>  2     2 F            6 0.611 Cladgrac, Cladphyl, Cladrang, Dicrfusc, Pleuschr,…
#>  3     3 B            5 0.612 Cladgrac, Cladphyl, Cladrang, Dicrfusc, Pleuschr  
#>  4     4 F            6 0.746 Cladgrac, Cladphyl, Cladrang, Cladstel, Dicrfusc,…
#>  5     5 B            5 0.746 Cladgrac, Cladrang, Cladstel, Dicrfusc, Pleuschr  
#>  6     6 F            6 0.788 Cladgrac, Cladrang, Cladstel, Dicrfusc, Pleuschr,…
#>  7     7 F            7 0.846 Cladarbu, Cladgrac, Cladrang, Cladstel, Dicrfusc,…
#>  8     8 B            6 0.847 Cladarbu, Cladrang, Cladstel, Dicrfusc, Pleuschr,…
#>  9     9 F            7 0.880 Cladarbu, Cladrang, Cladstel, Dicrfusc, Empenigr,…
#> 10    10 F            8 0.900 Cladarbu, Cladrang, Cladstel, Dicrfusc, Empenigr,…
#> # ℹ 35 more rows
```

If the two matrices are not identical (e.g. species and environment),
this will keep adding columns until either `rho_threshold` is met or
they are all included. Note that in this case, it is not guaranteed that
this is the highest correlation possible when the two matrices differ.

## Random starts to explore the space

The `bv_multi` function runs bvstep for a number of random starts to
avoid local optima, here with 5 species to start, iterated 10 times. We
can set the `num_best_results` to set how many results to return. Here,
‘best’ above `rho_threshold` is determined first by minimum species and
then correlation, while below `rho_threshold` it is determined first by
correlation and then number of species. This is in keeping with the idea
of finding the fewest species to meet the threshold. To return all
steps, simply set `num_best_results` to the same value as
`num_restarts`.

``` r
bv_m <- bv_multi(
  ref_mat = varespec, comp_mat = varespec,
  ref_dist = "bray", comp_dist = "bray",
  rho_threshold = 0.95,
  return_type = "final",
  rand_start = TRUE, nrand = 5, num_restarts = 10
)

bv_m
#> # A tibble: 5 × 7
#>   random_start  step FB    num_vars  corr species                  num_tied_with
#>   <chr>        <dbl> <chr>    <int> <dbl> <chr>                            <int>
#> 1 10              16 B           12 0.955 Callvulg, Cladarbu, Cla…             6
#> 2 3               16 F           12 0.955 Callvulg, Cladarbu, Cla…             6
#> 3 6               18 B           12 0.955 Callvulg, Cladarbu, Cla…             6
#> 4 5               18 F           12 0.955 Callvulg, Cladarbu, Cla…             6
#> 5 9               12 F           12 0.955 Callvulg, Cladarbu, Cla…             6
```

The default `return_type = 'final'` gives the best outcome of each
random start, for the best `num_best_results`. If we want the full steps
of each of the `num_random_starts`, set `return_type = 'steps'`. This
can also be returned as a list, if `returndf = FALSE`.

``` r
bv_steps <- bv_multi(
  ref_mat = varespec, comp_mat = varespec,
  ref_dist = "bray", comp_dist = "bray",
  rho_threshold = 0.95,
  return_type = "steps",
  rand_start = TRUE, nrand = 5, num_restarts = 10
)
bv_steps
#> # A tibble: 86 × 6
#>    random_start  step FB    num_vars  corr species                              
#>    <chr>        <dbl> <chr>    <int> <dbl> <chr>                                
#>  1 4                1 <NA>         5 0.342 Cladamau, Cladarbu, Claddefo, Empeni…
#>  2 4                2 F            6 0.583 Cladamau, Cladarbu, Claddefo, Cladst…
#>  3 4                3 F            7 0.712 Cladamau, Cladarbu, Claddefo, Cladra…
#>  4 4                4 B            6 0.712 Cladamau, Cladarbu, Cladrang, Cladst…
#>  5 4                5 B            5 0.712 Cladarbu, Cladrang, Cladstel, Empeni…
#>  6 4                6 F            6 0.809 Cladarbu, Cladrang, Cladstel, Empeni…
#>  7 4                7 F            7 0.854 Cladarbu, Cladrang, Cladstel, Empeni…
#>  8 4                8 B            6 0.855 Cladarbu, Cladrang, Cladstel, Empeni…
#>  9 4                9 F            7 0.880 Cladarbu, Cladrang, Cladstel, Dicrfu…
#> 10 4               10 F            8 0.900 Cladarbu, Cladrang, Cladstel, Dicrfu…
#> # ℹ 76 more rows
```

With `return_type = 'unique'`, we return the best `num_best_results`
from all steps in all random starts. The first line of this should match
the first line of `return_type = 'final'`, since that is the best result
overall. After that, they may differ as the penultimate set from a
particular random start might be better than the final of some others.

``` r
bv_unique <- bv_multi(
  ref_mat = varespec, comp_mat = varespec,
  ref_dist = "bray", comp_dist = "bray",
  rho_threshold = 0.95,
  return_type = "unique",
  rand_start = TRUE, nrand = 5, num_restarts = 10
)
bv_unique
#> # A tibble: 5 × 7
#>   random_start  step FB    num_vars  corr species                  num_tied_with
#>   <chr>        <dbl> <chr>    <int> <dbl> <chr>                            <int>
#> 1 3               16 F           12 0.955 Callvulg, Cladarbu, Cla…             6
#> 2 7               16 F           12 0.955 Callvulg, Cladarbu, Cla…             6
#> 3 2               14 F           12 0.955 Callvulg, Cladarbu, Cla…             6
#> 4 5               18 F           12 0.955 Callvulg, Cladarbu, Cla…             6
#> 5 6               18 F           12 0.955 Callvulg, Cladarbu, Cla…             6
```

## Peels

The `peel` function runs `bv_multi` iteratively, removing the best set
each time.

``` r
peels <- peel(
  ref_mat = varespec,
  comp_mat = varespec,
  nrand = 6,
  num_restarts = 10,
  corr_method = "spearman"
)
peels
#> # A tibble: 11 × 7
#>     peel  step FB    num_vars     corr species                     num_tied_with
#>    <dbl> <dbl> <chr>    <int>    <dbl> <chr>                               <int>
#>  1     1    12 F            5  0.962   Cladarbu, Cladrang, Cladst…             5
#>  2     2    11 F           12  0.687   Cladbotr, Cladchlo, Cladde…             1
#>  3     3    12 F            7  0.399   Betupube, Cetrisla, Cladam…             1
#>  4     4    16 F            7  0.320   Barbhatc, Cladcris, Descfl…             3
#>  5     5     5 F            4  0.238   Callvulg, Cladphyl, Nephar…             2
#>  6     6     4 B            3  0.169   Cetreric, Cladcocc, Cladco…             2
#>  7     7     5 B            2  0.121   Empenigr, Vacculig                     10
#>  8     8     4 B            1  0.0200  Pinusylv                               10
#>  9     9     3 B            1 -0.00753 Diphcomp                               10
#> 10    10     2 B            1 -0.00943 Cladfimb                               10
#> 11    11     1 <NA>         1 -0.0964  Polyjuni                               10
```

There are a number of user-defineable options in each of those
functions, see their documentation.

THere are also two potentially useful helper functions, `extract_final`,
which gets the last step in `bvstep` output, and `extract_names`. The
`bvstep` output has names in a single string with comma-separated
species names, and we often want them as a character vector. The
`extract_names` function parses this.

``` r
best_bv <- extract_names(bvout, step = "last")
best_bv
#>  [1] "Callvulg" "Cladarbu" "Cladrang" "Cladstel" "Cladunci" "Dicrfusc"
#>  [7] "Dicrsp"   "Empenigr" "Pleuschr" "Rhodtome" "Vaccmyrt" "Vaccviti"
```
