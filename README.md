
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
bvout <- bvstep(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                   rand_start = TRUE, nrand = 5)
bvout
#> # A tibble: 16 × 5
#>     step FB    num_vars  corr species                                           
#>    <dbl> <chr>    <int> <dbl> <chr>                                             
#>  1     1 <NA>         5 0.149 Cladchlo, Cladunci, Empenigr, Pohlnuta, Polycomm  
#>  2     2 B            4 0.171 Cladchlo, Cladunci, Pohlnuta, Polycomm            
#>  3     3 F            5 0.431 Cladchlo, Cladunci, Pleuschr, Pohlnuta, Polycomm  
#>  4     4 F            6 0.594 Cladchlo, Cladstel, Cladunci, Pleuschr, Pohlnuta,…
#>  5     5 F            7 0.735 Cladchlo, Cladrang, Cladstel, Cladunci, Pleuschr,…
#>  6     6 B            6 0.735 Cladchlo, Cladrang, Cladstel, Cladunci, Pleuschr,…
#>  7     7 F            7 0.774 Cladchlo, Cladrang, Cladstel, Cladunci, Empenigr,…
#>  8     8 F            8 0.818 Cladarbu, Cladchlo, Cladrang, Cladstel, Cladunci,…
#>  9     9 F            9 0.862 Cladarbu, Cladchlo, Cladrang, Cladstel, Cladunci,…
#> 10    10 B            8 0.863 Cladarbu, Cladchlo, Cladrang, Cladstel, Cladunci,…
#> 11    11 F            9 0.891 Cladarbu, Cladchlo, Cladrang, Cladstel, Cladunci,…
#> 12    12 B            8 0.891 Cladarbu, Cladrang, Cladstel, Cladunci, Dicrfusc,…
#> 13    13 F            9 0.911 Cladarbu, Cladrang, Cladstel, Cladunci, Dicrfusc,…
#> 14    14 F           10 0.933 Cladarbu, Cladrang, Cladstel, Cladunci, Dicrfusc,…
#> 15    15 F           11 0.947 Callvulg, Cladarbu, Cladrang, Cladstel, Cladunci,…
#> 16    16 F           12 0.955 Callvulg, Cladarbu, Cladrang, Cladstel, Cladunci,…
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
#> 1 2               14 B           12 0.955 Callvulg, Cladarbu, Cla…             6
#> 2 4               18 F           12 0.955 Callvulg, Cladarbu, Cla…             6
#> 3 5               16 B           12 0.955 Callvulg, Cladarbu, Cla…             6
#> 4 6               18 F           12 0.955 Callvulg, Cladarbu, Cla…             6
#> 5 10              14 B           12 0.955 Callvulg, Cladarbu, Cla…             6
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
#> # A tibble: 80 × 6
#>    random_start  step FB    num_vars   corr species                             
#>    <chr>        <dbl> <chr>    <int>  <dbl> <chr>                               
#>  1 6                1 <NA>         5 0.0476 Claddefo, Cladsp, Flavniva, Peltaph…
#>  2 6                2 B            4 0.197  Cladsp, Flavniva, Peltapht, Polypili
#>  3 6                3 B            3 0.200  Flavniva, Peltapht, Polypili        
#>  4 6                4 B            2 0.205  Flavniva, Polypili                  
#>  5 6                5 F            3 0.375  Flavniva, Pleuschr, Polypili        
#>  6 6                6 B            2 0.378  Pleuschr, Polypili                  
#>  7 6                7 B            1 0.381  Pleuschr                            
#>  8 6                8 F            2 0.579  Cladrang, Pleuschr                  
#>  9 6                9 F            3 0.732  Cladrang, Cladstel, Pleuschr        
#> 10 6               10 F            4 0.779  Cladrang, Cladstel, Pleuschr, Vaccv…
#> # ℹ 70 more rows
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
#> 1 6               14 F           12 0.955 Callvulg, Cladarbu, Cla…             5
#> 2 7               18 B           12 0.955 Callvulg, Cladarbu, Cla…             5
#> 3 2               18 F           12 0.955 Callvulg, Cladarbu, Cla…             5
#> 4 9               14 F           12 0.955 Callvulg, Cladarbu, Cla…             5
#> 5 10              14 F           12 0.955 Callvulg, Cladarbu, Cla…             5
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
#> # A tibble: 7 × 7
#>    peel  step FB    num_vars   corr species                        num_tied_with
#>   <dbl> <dbl> <chr>    <int>  <dbl> <chr>                                  <int>
#> 1     1     8 F            5  0.962 Cladarbu, Cladrang, Cladstel,…             2
#> 2     2    12 F           11  0.687 Cladbotr, Cladchlo, Claddefo,…             1
#> 3     3    16 F            7  0.407 Betupube, Cetrisla, Cladcerv,…             1
#> 4     4    11 F            8  0.321 Barbhatc, Callvulg, Cladamau,…             3
#> 5     5     6 F            5  0.284 Cladcorn, Cladcris, Descflex,…             1
#> 6     6     5 F            4  0.132 Cetreric, Cladcocc, Empenigr,…             7
#> 7     7     1 <NA>         4 -0.139 Cladfimb, Diphcomp, Pinusylv,…             1
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
#>  [7] "Dicrsp"   "Empenigr" "Pleuschr" "Ptilcili" "Vaccmyrt" "Vaccviti"
```
