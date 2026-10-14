# Bone Marrow Transplant (BMT) Dataset

## Overview

The `bmt` dataset contains clinical information about patients who underwent bone marrow transplantation. It is distributed with the **KMsurv** R package and is commonly used to study survival data and time-to-event outcomes.

- **Number of observations:** 137
- **Number of variables:** 22
- **Dataset name:** `bmt`
- **Source:** KMsurv R package

## What Does the Dataset Contain?

The dataset includes information about patient and donor characteristics, disease groups, transplant-related factors, follow-up times, and clinical events.

Key information includes:

- **Patient characteristics:** Age and sex of patients.
- **Donor characteristics:** Age and sex of donors.
- **Disease information:** Disease groups and selected disease-related indicators.
- **Transplant-related factors:** Hospital and treatment-related variables.
- **CMV status:** Cytomegalovirus status of patients and donors.
- **Overall survival:** Follow-up time and death indicators.
- **Disease-free survival:** Follow-up time and indicators related to relapse and disease-free survival.
- **Other clinical events:** Platelet recovery and graft-versus-host disease (GVHD).

Time variables are generally recorded in days. Event-indicator variables identify whether a particular event was observed. Some observations may be **censored**, meaning that the event of interest was not observed during the available follow-up period.

## What Can This Dataset Be Used For?

The dataset can be used to investigate questions such as:

- How do patient ages vary across disease groups?
- What are the characteristics of patients and donors?
- How do overall survival patterns differ between disease groups?
- How does disease-free survival vary across groups?
- What can the recorded times reveal about relapse, platelet recovery, and GVHD?

These are potential research questions rather than conclusions established by the dataset itself.

## Dataset Source

The dataset is included in the **KMsurv** R package.

- **R package:** KMsurv
- **Dataset:** `bmt`
- **CRAN:** https://cran.r-project.org/package=KMsurv

The dataset can be loaded in R using:

```r
install.packages("KMsurv")
library(KMsurv)
data("bmt", package = "KMsurv")
```

## Important Considerations

- The dataset represents a specific clinical context and may not be representative of all bone marrow transplant patients.
- A recorded follow-up time does not necessarily mean that an event occurred; censored observations must be handled appropriately in survival analysis.
- Observed associations or differences do not establish causation or constitute medical advice.
