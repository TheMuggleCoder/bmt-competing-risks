# Random survival forest for time to first event (relapse OR death)
# This uses a combined endpoint, not separate competing-risk probabilities.
# Install once if needed: install.packages("randomForestSRC")

library(randomForestSRC)
library(survival)

analysis_data$any_event <- as.integer(analysis_data$event_status != 0)

set.seed(20261014)

rsf_model <- rfsrc(
  Surv(time, any_event) ~ disease_group + patient_age + patient_sex,
  data = analysis_data,
  ntree = 500,
  importance = TRUE
)

print(rsf_model)
print(vimp(rsf_model))
plot(rsf_model)
