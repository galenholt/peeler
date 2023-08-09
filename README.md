
<!-- README.md is generated from README.Rmd. Please edit that file -->

# peeler

<!-- badges: start -->

[![R-CMD-check](https://github.com/galenholt/peeler/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/galenholt/peeler/actions/workflows/R-CMD-check.yaml)
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
bvout <- bvstep(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                   rand_start = TRUE, nrand = 5)
bvout
#> # A tibble: 16 × 5
#>     step FB    num_vars   corr species                                          
#>    <dbl> <chr>    <int>  <dbl> <chr>                                            
#>  1     1 <NA>         5 0.0991 Cladamau, Cladcerv, Cladphyl, Rhodtome, Stersp   
#>  2     2 B            4 0.107  Cladamau, Cladphyl, Rhodtome, Stersp             
#>  3     3 B            3 0.107  Cladphyl, Rhodtome, Stersp                       
#>  4     4 F            4 0.394  Cladphyl, Pleuschr, Rhodtome, Stersp             
#>  5     5 F            5 0.587  Cladphyl, Cladrang, Pleuschr, Rhodtome, Stersp   
#>  6     6 F            6 0.739  Cladphyl, Cladrang, Cladstel, Pleuschr, Rhodtome…
#>  7     7 B            5 0.740  Cladrang, Cladstel, Pleuschr, Rhodtome, Stersp   
#>  8     8 F            6 0.785  Cladrang, Cladstel, Pleuschr, Rhodtome, Stersp, …
#>  9     9 F            7 0.837  Cladarbu, Cladrang, Cladstel, Pleuschr, Rhodtome…
#> 10    10 F            8 0.861  Cladarbu, Cladrang, Cladstel, Empenigr, Pleuschr…
#> 11    11 F            9 0.884  Cladarbu, Cladrang, Cladstel, Dicrfusc, Empenigr…
#> 12    12 F           10 0.904  Cladarbu, Cladrang, Cladstel, Dicrfusc, Dicrsp, …
#> 13    13 F           11 0.925  Cladarbu, Cladrang, Cladstel, Dicrfusc, Dicrsp, …
#> 14    14 F           12 0.936  Callvulg, Cladarbu, Cladrang, Cladstel, Dicrfusc…
#> 15    15 F           13 0.952  Callvulg, Cladarbu, Cladrang, Cladstel, Cladunci…
#> 16    16 B           12 0.951  Callvulg, Cladarbu, Cladrang, Cladstel, Cladunci…
```

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
bv_m <- bv_multi(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                 rho_threshold = 0.95,
                 return_type = 'final',
                   rand_start = TRUE, nrand = 5, num_restarts = 10)
bv_m
#> # A tibble: 5 × 7
#>   random_start  step FB    num_vars  corr species                  num_tied_with
#>   <chr>        <dbl> <chr>    <int> <dbl> <chr>                            <int>
#> 1 1               12 F           12 0.955 Barbhatc, Callvulg, Cla…             7
#> 2 10              14 B           12 0.955 Callvulg, Cladarbu, Cla…             7
#> 3 5               18 B           12 0.955 Callvulg, Cladarbu, Cla…             7
#> 4 8               12 F           12 0.955 Callvulg, Cladarbu, Cla…             7
#> 5 7               18 B           12 0.955 Callvulg, Cladarbu, Cla…             7
```

The default `return_type = 'final'` gives the best outcome of each
random start, for the best `num_best_results`. If we want the full steps
of each of the `num_random_starts`, set `return_type = 'steps'`. This
can also be returned as a list, if `returndf = FALSE`.

``` r
bv_steps <- bv_multi(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                 rho_threshold = 0.95,
                 return_type = 'steps',
                   rand_start = TRUE, nrand = 5, num_restarts = 10)
bv_steps
#> # A tibble: 82 × 6
#>    random_start  step FB    num_vars  corr species                              
#>    <chr>        <dbl> <chr>    <int> <dbl> <chr>                                
#>  1 5                1 <NA>         5 0.135 Cladcocc, Cladgrac, Nepharct, Polyju…
#>  2 5                2 B            4 0.144 Cladcocc, Cladgrac, Nepharct, Vaccvi…
#>  3 5                3 B            3 0.154 Cladcocc, Cladgrac, Nepharct         
#>  4 5                4 B            2 0.159 Cladcocc, Cladgrac                   
#>  5 5                5 F            3 0.412 Cladcocc, Cladgrac, Pleuschr         
#>  6 5                6 F            4 0.581 Cladcocc, Cladgrac, Cladrang, Pleusc…
#>  7 5                7 F            5 0.733 Cladcocc, Cladgrac, Cladrang, Cladst…
#>  8 5                8 F            6 0.781 Cladcocc, Cladgrac, Cladrang, Cladst…
#>  9 5                9 F            7 0.831 Cladarbu, Cladcocc, Cladgrac, Cladra…
#> 10 5               10 B            6 0.831 Cladarbu, Cladcocc, Cladrang, Cladst…
#> # ℹ 72 more rows
```

With `return_type = 'unique'`, we return the best `num_best_results`
from all steps in all random starts. The first line of this should match
the first line of `return_type = 'final'`, since that is the best result
overall. After that, they may differ as the penultimate set from a
particular random start might be better than the final of some others.

``` r
bv_unique <- bv_multi(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                 rho_threshold = 0.95,
                 return_type = 'unique',
                   rand_start = TRUE, nrand = 5, num_restarts = 10)
bv_unique
#> # A tibble: 5 × 7
#>   random_start  step FB    num_vars  corr species                  num_tied_with
#>   <chr>        <dbl> <chr>    <int> <dbl> <chr>                            <int>
#> 1 6               12 F           12 0.955 Callvulg, Cladarbu, Cla…             8
#> 2 8               16 B           12 0.955 Callvulg, Cladarbu, Cla…             8
#> 3 3               14 F           12 0.955 Callvulg, Cladarbu, Cla…             8
#> 4 1               14 B           12 0.955 Callvulg, Cladarbu, Cla…             8
#> 5 9               14 B           12 0.955 Callvulg, Cladarbu, Cla…             8
```

## Peels

The `peel` function runs `bv_multi` iteratively, removing the best set
each time.

``` r
peels <- peel(ref_mat = varespec,
                comp_mat = varespec,
                nrand = 6,
                num_restarts = 10,
                corr_method = 'spearman')
peels
#> # A tibble: 10 × 7
#>     peel  step FB    num_vars    corr species                      num_tied_with
#>    <dbl> <dbl> <chr>    <int>   <dbl> <chr>                                <int>
#>  1     1    12 B            5  0.962  Cladarbu, Cladrang, Cladste…             3
#>  2     2    20 F           13  0.669  Cladchlo, Cladgrac, Cladunc…             7
#>  3     3    11 F            6  0.351  Cetrisla, Cladbotr, Cladcoc…             1
#>  4     4     7 F            8  0.322  Barbhatc, Cladamau, Claddef…             5
#>  5     5    10 F            5  0.291  Betupube, Cetreric, Cladcer…             2
#>  6     6     4 B            3  0.277  Cladcorn, Cladphyl, Dicrpoly             5
#>  7     7     6 B            1  0.256  Polypili                                10
#>  8     8     5 B            1  0.194  Callvulg                                10
#>  9     9     4 B            1  0.115  Empenigr                                10
#> 10    10     1 <NA>         3 -0.0877 Diphcomp, Pinusylv, Polyjuni             4
```

There are a number of user-defineable options in each of those
functions, see their documentation.

THere are also two potentially useful helper functions, `extract_final`,
which gets the last step in `bvstep` output, and `extract_names`. The
`bvstep` output has names in a single string with comma-separated
species names, and we often want them as a character vector. The
`extract_names` function parses this.

``` r
best_bv <- extract_names(bvout, step = 'last')
best_bv
#>  [1] "Callvulg" "Cladarbu" "Cladrang" "Cladstel" "Cladunci" "Dicrfusc"
#>  [7] "Dicrsp"   "Empenigr" "Pleuschr" "Rhodtome" "Vaccmyrt" "Vaccviti"
```
