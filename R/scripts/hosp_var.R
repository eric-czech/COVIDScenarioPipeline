DEFAULT_DATA_FILEPATH  <- 'model_output/mid-west-coast-AZ-NV_NoNPI'
DEFAULT_GEODATA_FILENAME <- 'data/west-coast-AZ-NV/geodata.csv'
DEFAULT_CMD <- 'high'
DEFAULT_NCORE <- 1
DEFAULT_OUTPUT_DIR <- 'hospitalization'
DEFAULT_TEST_DATA_FILEPATH  <- 'model_output/unifiedNPI'
DEFAULT_TEST_EXPECTED_OUTPUT_PATH  <- 'tests/data/hospitalization/goldenNPI'
DEFAULT_TEST_GEODATA_FILENAME  <- DEFAULT_GEODATA_FILENAME

get_env_var <- function(name, default){
  if (Sys.getenv(name) != '') Sys.getenv(name) else default
}
TEST_DATA_FILEPATH <- get_env_var('HOSP_TEST_DATA_FILEPATH', DEFAULT_TEST_DATA_FILEPATH)
TEST_EXPECTED_OUTPUT_PATH <- get_env_var('HOSP_TEST_EXPECTED_OUTPUT_PATH', DEFAULT_TEST_EXPECTED_OUTPUT_PATH)
TEST_GEODATA_FILENAME <- get_env_var('HOSP_TEST_GEODATA_FILENAME', DEFAULT_GEODATA_FILENAME)