# Weibull parametric survival model for time to relapse
# Death before relapse is treated as censoring here, so this is not a direct
# estimate of relapse cumulative incidence in the presence of competing risks.

library(survival)

weibull_model <- survreg(
  Surv(time, event_status == 1) ~ disease_group + patient_age + patient_sex,
  data = analysis_data,
  dist = "weibull"
)

cat("\n--- Weibull model for relapse ---\n")
print(summary(weibull_model))

# Plot estimated survival curves for disease groups at typical age/sex values
new_patients <- data.frame(
  disease_group = levels(as.factor(analysis_data$disease_group)),
  patient_age = rep(mean(analysis_data$patient_age, na.rm = TRUE),
                    length(levels(as.factor(analysis_data$disease_group)))),
  patient_sex = rep(levels(as.factor(analysis_data$patient_sex))[1],
                    length(levels(as.factor(analysis_data$disease_group))))
)

weibull_curves <- survfit(weibull_model, newdata = new_patients)
plot(
  weibull_curves,
  xlab = "Follow-up time",
  ylab = "Probability of not yet having relapsed",
  main = "Weibull model: relapse by disease group",
  lwd = 2
)
legend(
  "topright",
  legend = levels(as.factor(analysis_data$disease_group)),
  col = seq_along(levels(as.factor(analysis_data$disease_group))),
  lwd = 2,
  bty = "n"
)
