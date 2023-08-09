
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
#> # A tibble: 12 × 5
#>     step FB    num_vars  corr species                                           
#>    <dbl> <chr>    <int> <dbl> <chr>                                             
#>  1     1 <NA>         5 0.589 Cladrang, Cladstel, Diphcomp, Polypili, Rhodtome  
#>  2     2 B            4 0.591 Cladrang, Cladstel, Polypili, Rhodtome            
#>  3     3 F            5 0.735 Cladrang, Cladstel, Pleuschr, Polypili, Rhodtome  
#>  4     4 F            6 0.784 Cladrang, Cladstel, Pleuschr, Polypili, Rhodtome,…
#>  5     5 B            5 0.785 Cladrang, Cladstel, Pleuschr, Rhodtome, Vaccviti  
#>  6     6 F            6 0.836 Cladarbu, Cladrang, Cladstel, Pleuschr, Rhodtome,…
#>  7     7 F            7 0.860 Cladarbu, Cladrang, Cladstel, Empenigr, Pleuschr,…
#>  8     8 F            8 0.884 Cladarbu, Cladrang, Cladstel, Dicrfusc, Empenigr,…
#>  9     9 F            9 0.904 Cladarbu, Cladrang, Cladstel, Dicrfusc, Dicrsp, E…
#> 10    10 F           10 0.924 Cladarbu, Cladrang, Cladstel, Dicrfusc, Dicrsp, E…
#> 11    11 F           11 0.935 Callvulg, Cladarbu, Cladrang, Cladstel, Dicrfusc,…
#> 12    12 F           12 0.951 Callvulg, Cladarbu, Cladrang, Cladstel, Cladunci,…
```

The `bv_multi` function runs bvstep for a number of random starts to
avoid local optima, here with 5 species to start, iterated 10 times.

``` r
bv_m <- bv_multi(ref_mat = varespec, comp_mat = varespec,
                   ref_dist = 'bray', comp_dist = 'bray',
                   rand_start = TRUE, nrand = 5, num_restarts = 10)
bv_m
#> # A tibble: 77 × 6
#>    random_start  step FB    num_vars  corr species                              
#>    <chr>        <dbl> <chr>    <int> <dbl> <chr>                                
#>  1 1                1 <NA>         5 0.154 Cladphyl, Cladsp, Dicrpoly, Vacculig…
#>  2 1                2 F            6 0.458 Cladphyl, Cladsp, Dicrpoly, Pleuschr…
#>  3 1                3 B            5 0.467 Cladphyl, Cladsp, Dicrpoly, Pleuschr…
#>  4 1                4 F            6 0.634 Cladphyl, Cladsp, Cladstel, Dicrpoly…
#>  5 1                5 F            7 0.783 Cladphyl, Cladrang, Cladsp, Cladstel…
#>  6 1                6 F            8 0.834 Cladarbu, Cladphyl, Cladrang, Cladsp…
#>  7 1                7 B            7 0.834 Cladarbu, Cladrang, Cladsp, Cladstel…
#>  8 1                8 B            6 0.834 Cladarbu, Cladrang, Cladstel, Dicrpo…
#>  9 1                9 F            7 0.858 Cladarbu, Cladrang, Cladstel, Dicrpo…
#> 10 1               10 F            8 0.882 Cladarbu, Cladrang, Cladstel, Dicrfu…
#> # ℹ 67 more rows
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
#> # A tibble: 8 × 6
#>    peel  step FB    num_vars   corr species                                     
#>   <dbl> <dbl> <chr>    <int>  <dbl> <chr>                                       
#> 1     1    10 F            7  0.975 Cladarbu, Cladrang, Cladstel, Dicrfusc, Dic…
#> 2     2    11 F           12  0.543 Betupube, Cetrisla, Claddefo, Cladgrac, Cla…
#> 3     3    11 F            8  0.350 Barbhatc, Cladchlo, Cladphyl, Cladsp, Descf…
#> 4     4     7 F            4  0.313 Cladbotr, Cladcris, Icmaeric, Rhodtome      
#> 5     5     5 B            2  0.221 Callvulg, Cladamau                          
#> 6     6     5 F            4  0.177 Cetreric, Cladcerv, Cladcocc, Cladcorn      
#> 7     7     4 B            3  0.131 Dicrpoly, Empenigr, Vacculig                
#> 8     8     1 <NA>         4 -0.139 Cladfimb, Diphcomp, Pinusylv, Polyjuni
```

There are a number of user-defineable options in each of those
functions, see their documentation.

THere are also two potentially useful helper functions, `extract_final`,
which gets the last step in `bvstep` output, and `extract_names`. The
`bvstep` output has names in a single string with comma-separated
species names, and we often want them as a character vector. The
`extract_names` function parses this.

``` r
extract_names(bvout, step = 'last')
```
