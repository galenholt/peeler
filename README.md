
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

You can use `bvstep` alone

``` r
bvout <- bvstep(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                   rand_start = TRUE, nrand = 5)
bvout
#> # A tibble: 18 × 5
#>     step FB    num_vars  corr species                                           
#>    <dbl> <chr>    <int> <dbl> <chr>                                             
#>  1     1 <NA>         5 0.131 Cladcorn, Cladfimb, Cladgrac, Flavniva, Nepharct  
#>  2     2 B            4 0.158 Cladfimb, Cladgrac, Flavniva, Nepharct            
#>  3     3 B            3 0.189 Cladgrac, Flavniva, Nepharct                      
#>  4     4 B            2 0.228 Cladgrac, Flavniva                                
#>  5     5 F            3 0.414 Cladgrac, Cladstel, Flavniva                      
#>  6     6 F            4 0.592 Cladgrac, Cladrang, Cladstel, Flavniva            
#>  7     7 F            5 0.736 Cladgrac, Cladrang, Cladstel, Flavniva, Pleuschr  
#>  8     8 F            6 0.776 Cladgrac, Cladrang, Cladstel, Flavniva, Pleuschr,…
#>  9     9 B            5 0.779 Cladgrac, Cladrang, Cladstel, Pleuschr, Vaccviti  
#> 10    10 F            6 0.831 Cladarbu, Cladgrac, Cladrang, Cladstel, Pleuschr,…
#> 11    11 B            5 0.832 Cladarbu, Cladrang, Cladstel, Pleuschr, Vaccviti  
#> 12    12 F            6 0.855 Cladarbu, Cladrang, Cladstel, Empenigr, Pleuschr,…
#> 13    13 F            7 0.880 Cladarbu, Cladrang, Cladstel, Dicrfusc, Empenigr,…
#> 14    14 F            8 0.900 Cladarbu, Cladrang, Cladstel, Dicrfusc, Empenigr,…
#> 15    15 F            9 0.920 Cladarbu, Cladrang, Cladstel, Dicrfusc, Dicrsp, E…
#> 16    16 F           10 0.933 Cladarbu, Cladrang, Cladstel, Cladunci, Dicrfusc,…
#> 17    17 F           11 0.947 Callvulg, Cladarbu, Cladrang, Cladstel, Cladunci,…
#> 18    18 F           12 0.955 Callvulg, Cladarbu, Cladrang, Cladstel, Cladunci,…
```

The `bv_multi` function runs bvstep for a number of random starts to
avoid local optima, here with 5 species to start, iterated 10 times.

``` r
bv_m <- bv_multi(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                   rand_start = TRUE, nrand = 5, num_restarts = 10)
bv_m
#> # A tibble: 72 × 6
#>    random_start  step FB    num_vars  corr species                              
#>    <chr>        <dbl> <chr>    <int> <dbl> <chr>                                
#>  1 10               1 <NA>         5 0.193 Barbhatc, Cetrisla, Dicrsp, Hylosple…
#>  2 10               2 B            4 0.193 Cetrisla, Dicrsp, Hylosple, Ptilcili 
#>  3 10               3 F            5 0.419 Cetrisla, Cladstel, Dicrsp, Hylosple…
#>  4 10               4 B            4 0.419 Cladstel, Dicrsp, Hylosple, Ptilcili 
#>  5 10               5 F            5 0.582 Cladstel, Dicrsp, Hylosple, Pleuschr…
#>  6 10               6 F            6 0.746 Cladrang, Cladstel, Dicrsp, Hylosple…
#>  7 10               7 F            7 0.811 Cladrang, Cladstel, Dicrsp, Hylosple…
#>  8 10               8 F            8 0.855 Cladarbu, Cladrang, Cladstel, Dicrsp…
#>  9 10               9 F            9 0.883 Cladarbu, Cladrang, Cladstel, Dicrsp…
#> 10 10              10 F           10 0.913 Cladarbu, Cladrang, Cladstel, Dicrfu…
#> # ℹ 62 more rows
```

And finally, `peel` runs `bv_multi` iteratively, removing the best set
each time.

``` r
peels <- peel(ref_mat = varespec,
                comp_mat = varespec,
                nrand = 6,
                num_restarts = 10,
                corr_method = 'spearman')
peels
#> # A tibble: 7 × 6
#>    peel  step FB    num_vars   corr species                                     
#>   <dbl> <dbl> <chr>    <int>  <dbl> <chr>                                       
#> 1     1     7 F            8  0.975 Cladarbu, Cladrang, Cladstel, Dicrfusc, Dic…
#> 2     2    11 F           12  0.545 Cetrisla, Cladchlo, Claddefo, Cladgrac, Cla…
#> 3     3    11 F            6  0.351 Callvulg, Cladbotr, Cladphyl, Flavniva, Pel…
#> 4     4     8 F            7  0.323 Barbhatc, Betupube, Cladcris, Cladsp, Descf…
#> 5     5     7 F            4  0.177 Cetreric, Cladcerv, Cladcocc, Cladcorn      
#> 6     6     4 B            3  0.121 Cladamau, Empenigr, Vacculig                
#> 7     7     1 <NA>         4 -0.139 Cladfimb, Diphcomp, Pinusylv, Polyjuni
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
