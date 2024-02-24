# Hans D. Escobar H.

# Check required packages are installed

if (!require("lme4", quietly = TRUE)) {
  print("Error: missing lme4 package")
  quit()
}

# Load data and make Linear Mixed-Effects models

dat <- read.table("../Example_Data/pelargo.txt", header = TRUE)
subachoque <- dat[dat$Location == "1", ]
sumapaz <- dat[dat$Location == "2", ]
lme_subachoque <- lmer(Pelargonina ~ (1 | Line), data = subachoque)
lme_sumapaz <- lmer(Pelargonina ~ (1 | Line), data = sumapaz)


if (!dir.exists("../Results")) {
  dir.create("../Results")
}

sink("../Results/lme_subachoque.txt")
summary(lme_subachoque)
sink()

sink("../Results/lme_sumapaz.txt")
summary(lme_sumapaz)
sink()
