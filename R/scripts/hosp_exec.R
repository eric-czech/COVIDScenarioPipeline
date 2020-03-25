library(covidcommon)
library(hospitalization)
library(readr)
library(assertthat)
library(glue)

hosp_exec <-
  function(data_filepath,
           geodata_filename,
           cmd,
           ncore,
           output_dir,
           seed = 123456789) {
    set.seed(seed)
    
    # Check that environment variable required for this function to run properly
    # (in covidcommon::config) is present
    config_path <- Sys.getenv('CONFIG_PATH')
    assert_that(length(config_path) > 0,
                msg = "Environment variable 'CONFIG_PATH' must be set (e.g. config.yml)")
    assert_that(file.exists(config_path), 
                msg = glue("Config path set in environment variable CONFIG_PATH as {config_path} does not exist"))
    
    # set parameters for time to hospitalization, time to death, time to discharge
    time_hosp_pars <- as_evaled_expression(config$hospitalization$parameters$time_hosp)
    time_disch_pars <- as_evaled_expression(config$hospitalization$parameters$time_disch)
    time_death_pars <- as_evaled_expression(config$hospitalization$parameters$time_death)
    time_ICU_pars <- as_evaled_expression(config$hospitalization$parameters$time_ICU)
    time_ICUdur_pars <- as_evaled_expression(config$hospitalization$parameters$time_ICUdur)
    time_vent_pars <- as_evaled_expression(config$hospitalization$parameters$time_vent)
    mean_inc <- as_evaled_expression(config$hospitalization$parameters$mean_inc)
    dur_inf_shape <- as_evaled_expression(config$hospitalization$parameters$inf_shape)
    dur_inf_scale <- as_evaled_expression(config$hospitalization$parameters$inf_scale)
    end_date = config$hospitalization$parameters$end
    
    # set death + hospitalization parameters
    p_death <- as_evaled_expression(config$hospitalization$parameters$p_death)
    p_death_rate <- as_evaled_expression(config$hospitalization$parameters$p_death_rate)
    p_ICU <- as_evaled_expression(config$hospitalization$parameters$p_ICU)
    p_vent <- as_evaled_expression(config$hospitalization$parameters$p_vent)
    
    names(p_death) = c('low', 'med', 'high')
    
    county_dat <- read.csv(geodata_filename)
    county_dat$geoid <- as.character(county_dat$geoid)
    county_dat$new_pop <- county_dat$pop2010
    #county_dat <- make_metrop_labels(county_dat)
    target_geo_ids <- county_dat$geoid[county_dat$stateUSPS == "CA"]
    
    build_hospdeath_par(
      p_hosp = p_death[cmd] * 10,
      p_death = p_death_rate,
      p_vent = p_vent,
      p_ICU = p_ICU,
      time_hosp_pars = time_hosp_pars,
      time_death_pars = time_death_pars,
      time_disch_pars = time_disch_pars,
      time_ICU_pars = time_ICU_pars,
      time_vent_pars = time_vent_pars,
      time_ICUdur_pars = time_ICUdur_pars,
      end_date = end_date,
      cores = ncore,
      data_filename = data_filepath,
      scenario_name = paste(cmd, "death", sep = "_"),
      target_geo_ids = target_geo_ids,
      root_out_dir = output_dir
    )
    
  }
