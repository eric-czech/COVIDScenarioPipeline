# TODO: Assets in here should come from a package namespace instead, but since this
# project isn't a package and making it one would cause a lot of namespace collisions
# due to replicated files, stick with the convention of sourcing relative paths
# from the top-level of the project
source('R/scripts/hosp_exec.R')
source('R/scripts/hosp_var.R')

# TODO: Use CLI parsing framework instead
args <- commandArgs(trailingOnly = TRUE)

get_arg <- function(i, default) {
  if (length(args) >= i) args[i] else default
}
data_filepath    <- get_arg(1, DEFAULT_DATA_FILEPATH)
geodata_filename <- get_arg(2, DEFAULT_GEODATA_FILENAME)
cmd              <- get_arg(3, DEFAULT_CMD)
ncore            <- as.numeric(get_arg(4, DEFAULT_NCORE))
output_dir       <- get_arg(5, DEFAULT_OUTPUT_DIR)

# TODO: Add logging framework
print(
  glue(
    'Executing script with arguments:
    |  data_filepath = {data_filepath}
    |  geodata_filename = {geodata_filename}
    |  cmd = {cmd}
    |  ncore = {ncore}
    |  output_dir = {output_dir}',
    trim=F
  )
)

hosp_exec(data_filepath, geodata_filename, cmd, ncore, output_dir)
