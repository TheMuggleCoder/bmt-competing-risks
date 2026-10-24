# Log-normal accelerated failure time (AFT) model for time to relapse
# Death before relapse is treated as censoring here; this is not a direct
# competing-risk cumulative-incidence model.

library(survival)

aft_model <- survreg(
  Surv(time, event_status == 1) ~ disease_group + patient_age + patient_sex,
  data = analysis_data,
  dist = "lognormal"
)

cat("\n--- Log-normal AFT model for relapse ---\n")
print(summary(aft_model))

new_patients <- data.frame(
  disease_group = levels(as.factor(analysis_data$disease_group)),
  patient_age = rep(mean(analysis_data$patient_age, na.rm = TRUE),
                    length(levels(as.factor(analysis_data$disease_group)))),
  patient_sex = rep(levels(as.factor(analysis_data$patient_sex))[1],
                    length(levels(as.factor(analysis_data$disease_group))))
)

aft_curves <- survfit(aft_model, newdata = new_patients)
plot(
  aft_curves,
  xlab = "Follow-up time",
  ylab = "Probability of not yet having relapsed",
  main = "Log-normal AFT model: relapse by disease group",
  lwd = 2
)
legend(
  "topright",
  legend = levels(as.factor(analysis_data$disease_group)),
  col = seq_along(levels(as.factor(analysis_data$disease_group))),
  lwd = 2,
  bty = "n"
)
