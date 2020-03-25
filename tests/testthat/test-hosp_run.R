context("hospitalization simulation script")
# TODO: Both the working dir change and the source calls should be removed if the 
# project moves to a package structure (right now many relative paths from
# the top level of the project are hard-coded)
setwd("../..")
source('R/scripts/hosp_var.R')
source('R/scripts/hosp_exec.R')
library(fs)
library(readr)
library(dplyr)
library(purrr)
library(glue)

test_that("script produces correct results on manually curated input/output set", {
  
  # Run the hospitalization script with a temporary output directory
  output_dir <- tempdir()
  hosp_exec(
    data_filepath=TEST_DATA_FILEPATH,
    geodata_filename=TEST_GEODATA_FILENAME,
    cmd=DEFAULT_CMD,
    ncore=DEFAULT_NCORE,
    output_dir=output_dir
  )
  
  # Load expected results and those produced above
  load_results <- function(dir){
    # Suppress readr/dplyr warnings since downstream equality check will indicate if they are important
    read <- function(f) suppressWarnings(read_csv(f, col_types=cols())) %>% mutate(f=path_file(f))
    dir_ls(dir) %>% sort %>% map(read)
  }
  dfsa <- load_results(file.path(output_dir, TEST_DATA_FILEPATH))
  dfse <- load_results(TEST_EXPECTED_OUTPUT_PATH)
  
  # * Assert consecutively more detailed conditions to aid in debugging in the event of 
  #   any inequalities (i.e. avoid one single big data frame comparison)
  
  # Ensure the same number of simulation files were produced
  expect_equal(length(dfsa), length(dfse), info='Number of simulation output files not equal')
  
  # Ensure that the same number of rows was produced for each file
  tally_by_file <- function(df) df %>% group_by(f) %>% tally %>% ungroup
  cta <- tally_by_file(dfsa %>% bind_rows)
  cte <- tally_by_file(dfse %>% bind_rows)
  status <- all_equal(cta, cte)
  if (!isTRUE(status)){
    cat('\nNumber of rows not equal in every simulation result file; counts by file:\n')
    print(cta)
    print(cte)
    fail('Number of rows not equal in every simulation result file')
  }
  
  # Ensure that the content of each file is the same
  validate_sim_results <- function(df1, df2) {
    expect_equal(df1$f[1], df2$f[1])
    status <- all_equal(df1, df2, convert=TRUE)
    list(file=df1$f[1], status=status)
  }
  for (res in map2(dfsa, dfse, validate_sim_results)) {
    if (!isTRUE(res$status)){
      fail(glue('Results do not match for file "{res$file}"; Reason: {res$status}'))
    }
  }
})
