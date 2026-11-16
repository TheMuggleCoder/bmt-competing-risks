# Automated checks for the BMT analysis.
# Run from the project folder:  testthat::test_dir("tests")

library(testthat)

# test_dir() runs from the tests/ folder, so load the data from the project root
project_root <- if (file.exists("01_preprocessing.R")) "." else ".."
old_wd <- setwd(project_root)
invisible(capture.output(source("01_preprocessing.R")))   # hide its console messages
setwd(old_wd)

test_that("data has 137 patients and no missing values", {
  expect_equal(nrow(analysis_data), 137)
  expect_equal(sum(is.na(bmt)), 0)
  expect_equal(sum(duplicated(bmt)), 0)
})

test_that("competing-risks outcome is coded correctly", {
  expect_true(all(analysis_data$event_status %in% c(0, 1, 2)))
  expect_equal(sum(analysis_data$event_status == 1), 42)   # relapse first
  expect_equal(sum(analysis_data$event_status == 2), 41)   # death before relapse
  expect_equal(sum(analysis_data$event_status == 0), 54)   # censored
  expect_true(all((analysis_data$event_status > 0) == (analysis_data$dfs_event == 1)))
})

test_that("reference groups are ALL and female", {
  expect_equal(levels(analysis_data$disease_group)[1], "ALL")
  expect_equal(levels(analysis_data$patient_sex)[1], "Female")
})

test_that("group sizes add up to all patients", {
  group_sizes <- table(analysis_data$disease_group)
  expect_equal(length(group_sizes), 3)
  expect_equal(sum(group_sizes), 137)
})

test_that("Kaplan-Meier gives three valid curves and groups differ", {
  km_fit <- survfit(Surv(os_days, died) ~ disease_group, data = analysis_data)
  expect_equal(length(km_fit$strata), 3)
  expect_true(all(km_fit$surv >= 0 & km_fit$surv <= 1))
  logrank <- survdiff(Surv(os_days, died) ~ disease_group, data = analysis_data)
  p_value <- pchisq(logrank$chisq, df = 2, lower.tail = FALSE)
  expect_lt(p_value, 0.05)
})

test_that("cumulative incidences never exceed 100%", {
  cif <- cuminc(analysis_data$time, analysis_data$event_status, cencode = 0)
  at_end <- timepoints(cif, times = max(analysis_data$time))$est
  expect_lte(sum(at_end[, 1]), 1)
})

test_that("Aalen-Johansen is below the naive 1 - KM, as theory says", {
  cif   <- cuminc(analysis_data$time, analysis_data$event_status, cencode = 0)
  aj    <- timepoints(cif, times = 365)$est[1, 1]
  naive <- 1 - summary(survfit(Surv(time, relapse_event) ~ 1, data = analysis_data),
                       times = 365)$surv
  expect_lt(aj, naive)
})

test_that("Cox model returns four positive hazard ratios", {
  cox <- coxph(Surv(time, relapse_event) ~ disease_group + age10 + patient_sex,
               data = analysis_data)
  hr <- exp(coef(cox))
  expect_equal(length(hr), 4)
  expect_true(all(hr > 0))
  expect_true("GLOBAL" %in% rownames(cox.zph(cox)$table))
})

test_that("Fine-Gray model converges with four estimates", {
  covariates <- model.matrix(~ disease_group + age10 + patient_sex, data = analysis_data)[, -1]
  fg <- crr(analysis_data$time, analysis_data$event_status, cov1 = covariates,
            failcode = 1, cencode = 0)
  expect_true(fg$converged)
  expect_equal(length(fg$coef), 4)
})

test_that("true cumulative incidence formula is correct", {
  true_cif <- function(relapse_rate, death_rate, tau) {
    relapse_rate / (relapse_rate + death_rate) * (1 - exp(-(relapse_rate + death_rate) * tau))
  }
  expect_equal(true_cif(0.08, 0.08, 5), 0.2753, tolerance = 1e-3)
  expect_equal(true_cif(0.08, 0, 5), 1 - exp(-0.4), tolerance = 1e-10)
})