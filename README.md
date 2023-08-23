
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
#>     step FB    num_vars  corr species                                           
#>    <dbl> <chr>    <int> <dbl> <chr>                                             
#>  1     1 <NA>         5 0.131 Cladcris, Empenigr, Hylosple, Polyjuni, Ptilcili  
#>  2     2 B            4 0.148 Cladcris, Hylosple, Polyjuni, Ptilcili            
#>  3     3 B            3 0.165 Cladcris, Hylosple, Ptilcili                      
#>  4     4 F            4 0.424 Cladcris, Cladstel, Hylosple, Ptilcili            
#>  5     5 F            5 0.610 Cladcris, Cladrang, Cladstel, Hylosple, Ptilcili  
#>  6     6 F            6 0.742 Cladcris, Cladrang, Cladstel, Hylosple, Pleuschr,…
#>  7     7 F            7 0.795 Cladcris, Cladrang, Cladstel, Hylosple, Pleuschr,…
#>  8     8 F            8 0.839 Cladarbu, Cladcris, Cladrang, Cladstel, Hylosple,…
#>  9     9 B            7 0.839 Cladarbu, Cladrang, Cladstel, Hylosple, Pleuschr,…
#> 10    10 F            8 0.867 Cladarbu, Cladrang, Cladstel, Empenigr, Hylosple,…
#> 11    11 F            9 0.892 Cladarbu, Cladrang, Cladstel, Dicrfusc, Empenigr,…
#> 12    12 F           10 0.913 Cladarbu, Cladrang, Cladstel, Dicrfusc, Dicrsp, E…
#> 13    13 F           11 0.930 Cladarbu, Cladrang, Cladstel, Dicrfusc, Dicrsp, E…
#> 14    14 F           12 0.944 Cladarbu, Cladrang, Cladstel, Cladunci, Dicrfusc,…
#> 15    15 F           13 0.961 Callvulg, Cladarbu, Cladrang, Cladstel, Cladunci,…
#> 16    16 B           12 0.955 Callvulg, Cladarbu, Cladrang, Cladstel, Cladunci,…
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
#> 1 2               16 F           12 0.955 Callvulg, Cladarbu, Cla…             5
#> 2 10              16 F           12 0.955 Callvulg, Cladarbu, Cla…             5
#> 3 6               16 F           12 0.955 Callvulg, Cladarbu, Cla…             5
#> 4 1               18 F           12 0.955 Callvulg, Cladarbu, Cla…             5
#> 5 8               12 F           12 0.955 Callvulg, Cladarbu, Cla…             5
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
#> # A tibble: 78 × 6
#>    random_start  step FB    num_vars  corr species                              
#>    <chr>        <dbl> <chr>    <int> <dbl> <chr>                                
#>  1 1                1 <NA>         5 0.484 Betupube, Cetrisla, Cladarbu, Cladra…
#>  2 1                2 F            6 0.682 Betupube, Cetrisla, Cladarbu, Cladra…
#>  3 1                3 F            7 0.769 Betupube, Cetrisla, Cladarbu, Cladra…
#>  4 1                4 F            8 0.834 Betupube, Cetrisla, Cladarbu, Cladra…
#>  5 1                5 B            7 0.834 Betupube, Cladarbu, Cladrang, Cladst…
#>  6 1                6 F            8 0.856 Betupube, Cladarbu, Cladrang, Cladst…
#>  7 1                7 F            9 0.880 Betupube, Cladarbu, Cladrang, Cladst…
#>  8 1                8 B            8 0.880 Betupube, Cladarbu, Cladrang, Cladst…
#>  9 1                9 F            9 0.900 Betupube, Cladarbu, Cladrang, Cladst…
#> 10 1               10 F           10 0.920 Betupube, Cladarbu, Cladrang, Cladst…
#> # ℹ 68 more rows
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
#> 1 9               16 B           12 0.955 Callvulg, Cladarbu, Cla…             7
#> 2 3               18 B           12 0.955 Callvulg, Cladarbu, Cla…             7
#> 3 1               16 B           12 0.955 Callvulg, Cladarbu, Cla…             7
#> 4 5               14 F           12 0.955 Callvulg, Cladarbu, Cla…             7
#> 5 4               14 F           12 0.955 Callvulg, Cladarbu, Cla…             7
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
#> 1     1    12 B            5  0.962 Cladarbu, Cladrang, Cladstel,…             3
#> 2     2    12 F           13  0.692 Cladchlo, Claddefo, Cladgrac,…             1
#> 3     3     9 F            8  0.353 Barbhatc, Betupube, Callvulg,…             1
#> 4     4     5 F            8  0.327 Cladcorn, Cladcris, Cladsp, D…             1
#> 5     5     6 F            3  0.183 Cetrisla, Cladcerv, Cladcocc               6
#> 6     6     4 B            3  0.119 Cetreric, Cladamau, Empenigr               5
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
