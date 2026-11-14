# Competing Risks Analysis of Relapse after Bone Marrow Transplantation

Relapse is the main reason a bone marrow transplant fails, but many patients die before they
ever have the chance to relapse. Death therefore acts as a **competing risk**: once it happens,
relapse can no longer be observed. This project studies relapse in 137 patients with acute
leukaemia (the `bmt` dataset from the R package KMsurv) and shows why ignoring competing deaths
gives a wrong, inflated picture of relapse risk.

**Live dashboard:** https://YOUR-NAME.shinyapps.io/YOUR-APP/
**Docker image:** `abishek933/bmt-dashboard:1.0`
**Team:** Abishek Eswaramoorthy, Sumit Singh

---

## Research questions

1. How does overall survival differ between the three disease groups?
2. What is the real probability of relapse when death before relapse is taken into account?
3. How much does the common shortcut, 1 minus Kaplan-Meier, overstate relapse risk?
4. Which patient factors are linked to relapse, and does the answer depend on the model used?

## Data

| | |
|---|---|
| Source | Klein and Moeschberger (2003), `bmt` dataset in the R package KMsurv |
| Patients | 137, transplanted at four hospitals between 1984 and 1989 |
| Disease groups | ALL (38), AML low risk (54), AML high risk (45) |
| Outcome time | Disease-free survival time in days |
| Relapse first | 42 patients (event of interest, code 1) |
| Death before relapse | 41 patients (competing event, code 2) |
| Censored | 54 patients (still alive and relapse-free at last follow-up, code 0) |

## Methods

| Method | Question it answers | R function |
|---|---|---|
| Kaplan-Meier and log-rank test | How does overall survival differ by disease group? | `survfit()`, `survdiff()` |
| Aalen-Johansen cumulative incidence | What is the actual probability of relapse by a given time? | `cuminc()`, `timepoints()` |
| Gray's test | Does the relapse incidence differ between groups? | `cuminc(..., group = )` |
| Cause-specific Cox model | Which factors change the relapse **rate** among patients still alive? | `coxph()`, `cox.zph()` |
| Fine-Gray model | Which factors change the **probability** of relapse, deaths included? | `crr()` |
| Simulation study (500 repetitions, 6 scenarios) | How biased is 1 minus Kaplan-Meier compared with Aalen-Johansen? | base R |

Both regression models use the same covariates: disease group, age (per 10 years) and sex.

## Main findings

- Overall survival differs clearly between the disease groups (log-rank p < 0.05);
  AML low-risk patients do best.
- 1 minus Kaplan-Meier, which treats deaths as censored, is always higher than the Aalen-Johansen
  estimate of relapse. It counts patients who have already died as if they could still relapse.
- The simulation confirms this: the bias of 1 minus Kaplan-Meier grows as the death rate increases,
  while Aalen-Johansen stays close to the true value in every scenario.
- The Cox and Fine-Gray models answer different questions, so both are reported. The Cox model
  explains the biology (the relapse rate); the Fine-Gray model gives the risk a patient actually faces.

Full numbers are in `output/tables/` after running the analysis, and in the report.

---

## How to run

There are three ways to run the project. Choose one.

### Option 1: Docker (recommended, nothing else to install)

This needs only [Docker Desktop](https://www.docker.com/products/docker-desktop/). Open it and wait
until it shows **Running**.

**Run the ready-made image from Docker Hub:**
```
docker run -p 3838:3838 abishek933/bmt-dashboard:1.0
```
Then open http://localhost:3838 in your browser. Press `Ctrl + C` in the terminal to stop.

**Or build the image yourself from this repository:**
```
git clone https://github.com/TheMuggleCoder/bmt-competing-risks.git
cd bmt-competing-risks
docker build -t bmt-dashboard .
docker run -p 3838:3838 bmt-dashboard
```

**Run the automated tests inside Docker:**
```
docker run --rm bmt-dashboard Rscript -e "testthat::test_dir('tests')"
```
Expected result: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 24 ]`

### Option 2: RStudio

1. Install [R](https://cran.r-project.org) and [RStudio](https://posit.co/download/rstudio-desktop/).
2. Double-click **`BMT_Project.Rproj`**. RStudio opens in the project folder.
3. Open **`run_all.R`** and click **Source**. On the first run, missing packages are installed
   automatically. Results print in the Console and are saved in `output/`.
   The whole run takes about two minutes, most of it the simulation.
4. Open **`dashboard.Rmd`** and click **Run Document** to start the dashboard.
5. Run the tests from the Console: `testthat::test_dir("tests")`

### Option 3: Online

Open the live dashboard at the shinyapps.io link above. No installation is needed, but the code
cannot be changed from there.

---

## Project structure

```
BMT_Project/
├── 01_preprocessing.R          packages, data loading, readable names, competing-risks outcome
├── 02_eda.R                    summary table and six exploratory plots
├── 03_kaplan_meier.R           Kaplan-Meier overall survival by disease group, log-rank test
├── 04_cumulative_incidence.R   Aalen-Johansen incidence, Gray's test, comparison with 1 - KM
├── 05_cox_model.R              cause-specific Cox model for relapse, proportional hazards test
├── 06_fine_gray_model.R        Fine-Gray model for relapse
├── 07_model_comparison.R       Cox vs Fine-Gray table and forest plot
├── 08_simulation.R             simulation study: Aalen-Johansen vs 1 - Kaplan-Meier
├── run_all.R                   runs scripts 01 to 08 in order
├── dashboard.Rmd               interactive flexdashboard with six pages
├── tests/
│   └── test_analysis.R         24 automated checks with testthat
├── Dockerfile                  recipe for the Docker image
├── .dockerignore               files kept out of the image
├── GUIDE.html                  plain-language explanation of every method
├── BMT_Project.Rproj           RStudio project file
└── output/                     created when the scripts run
    ├── figures/                all plots as PNG
    └── tables/                 all result tables as CSV
```

Each script can also be run on its own; it loads the data first if needed.

## Dashboard

The flexdashboard (`dashboard.Rmd`) has six pages:

| Page | Content |
|---|---|
| Overview | Key numbers, event breakdown and study summary |
| Data | Patient characteristics, with filters by disease group |
| Survival | Kaplan-Meier curves and the log-rank test |
| Competing risks | Cumulative incidence curves and the naive 1 - KM comparison |
| Models | Cox and Fine-Gray results side by side |
| Simulation | Bias of 1 - KM vs Aalen-Johansen across scenarios |

## Reproducibility and testing

- **Docker** fixes the whole environment: R 4.6.1 (`rocker/r-ver`), the system libraries and every
  R package. The analysis therefore runs the same way on any computer.
- **testthat** runs 24 checks on the analysis, including:
  - 137 patients, no missing or duplicate rows;
  - event counts of 42 relapses, 41 deaths and 54 censored, matching the original `d3` indicator;
  - Kaplan-Meier probabilities between 0 and 1;
  - cumulative incidence that never exceeds 100% and that stays below 1 minus Kaplan-Meier;
  - Cox and Fine-Gray models that fit and converge;
  - a correct true-incidence formula for the simulation.
- **Git and GitHub** keep the full history of the code.
- **A fixed random seed** (`set.seed(20261014)`) makes the simulation give the same numbers on every run.

## Tools

| Tool | Used for |
|---|---|
| R 4.6.1 | All analysis |
| survival, cmprsk, survminer | Survival and competing-risks methods |
| dplyr, tidyr, ggplot2 | Data handling and plots |
| flexdashboard, shiny, rmarkdown | Interactive dashboard |
| testthat | Automated tests |
| Docker | Reproducible environment |
| shinyapps.io | Online hosting of the dashboard |
| GitHub | Version control and sharing |
| LaTeX | Written report |

## Team contributions

| Member | Work |
|---|---|
| Abishek Eswaramoorthy | Data preparation (01), exploratory analysis (02), Kaplan-Meier (03), dashboard and shinyapps.io deployment, GitHub, Docker and automated tests |
| Sumit Singh | Cumulative incidence (04), Cox and Fine-Gray models (05-07), simulation study (08), LaTeX report |

## Troubleshooting

| Problem | Fix |
|---|---|
| `cannot open file '01_preprocessing.R'` | Open the project with `BMT_Project.Rproj` so R starts in the right folder. |
| `there is no package called ...` | Run `install.packages("<name>")` in the Console. |
| `Cannot connect to the Docker daemon` | Open Docker Desktop and wait until it says Running. |
| `port is already allocated` | The dashboard is already running. Find it with `docker ps`, then `docker stop <id>`. |
| Dashboard opens very small in RStudio | Click **Open in Browser**. |

## References

- Klein, J. P. and Moeschberger, M. L. (2003). *Survival Analysis: Techniques for Censored
  and Truncated Data*, 2nd ed. Springer.
- Kaplan, E. L. and Meier, P. (1958). Nonparametric estimation from incomplete observations.
  *Journal of the American Statistical Association*, 53, 457-481.
- Cox, D. R. (1972). Regression models and life-tables. *Journal of the Royal Statistical
  Society, Series B*, 34, 187-220.
- Gray, R. J. (1988). A class of K-sample tests for comparing the cumulative incidence of a
  competing risk. *Annals of Statistics*, 16, 1141-1154.
- Fine, J. P. and Gray, R. J. (1999). A proportional hazards model for the subdistribution
  of a competing risk. *Journal of the American Statistical Association*, 94, 496-509.
- Putter, H., Fiocco, M. and Geskus, R. B. (2007). Tutorial in biostatistics: competing risks
  and multi-state models. *Statistics in Medicine*, 26, 2389-2430.
- Latouche, A., Allignol, A., Beyersmann, J., Labopin, M. and Fine, J. P. (2013). A competing risks
  analysis should report results on all cause-specific hazards and cumulative incidence functions.
  *Journal of Clinical Epidemiology*, 66, 648-653.
