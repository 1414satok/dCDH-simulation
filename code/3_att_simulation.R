library(dplyr)
library(tidyverse)
library(patchwork)
library(fixest)
library(DIDmultiplegt)
source("code/gen_data.R")

## simulate ATT

set.seed(1414)

n_simu <- 500 # the number of simulation
n_obs <- 1000
total_years <- 36

list_att1_twfe <- c()
list_att2_twfe <- c()
list_att3_twfe <- c()
list_att4_twfe <- c()

list_att1_dcdh <- c()
list_att2_dcdh <- c()
list_att3_dcdh <- c()
list_att4_dcdh <- c()

for(i in 1:n_simu){
  print(i)
  data <- make_simulation(n_obs, total_years)
  
  ## Two-way fixed effect model
  model1_twfe <- data |> 
    mutate(timeToTreatment = year - trTime) |>
    feols(
      y1 ~ i(timeToTreatment, ref = -1) |
        id + year, 
      data = _
    )
  model2_twfe <- data |> 
    mutate(timeToTreatment = year - trTime) |>
    feols(
      y2 ~ i(timeToTreatment, ref = -1) |
        id + year, 
      data = _
    )
  model3_twfe <- data |> 
    mutate(timeToTreatment = year - trTime) |>
    feols(
      y3 ~ i(timeToTreatment, ref = -1) |
        id + year, 
      data = _
    )
  model4_twfe <- data |> 
    mutate(timeToTreatment = year - trTime) |>
    feols(
      y4 ~ i(timeToTreatment, ref = -1) |
        id + year, 
      data = _
    )
  
  # de Chaisemartin and D'Haultf[oe]uille model
  model1_dcdh <- did_multiplegt(df = data, Y = "y1", G = "id", T = "year", D = "isTreated")
  model2_dcdh <- did_multiplegt(df = data, Y = "y2", G = "id", T = "year", D = "isTreated")
  model3_dcdh <- did_multiplegt(df = data, Y = "y3", G = "id", T = "year", D = "isTreated")
  model4_dcdh <- did_multiplegt(df = data, Y = "y4", G = "id", T = "year", D = "isTreated")
  
  list_att1_twfe <- c(list_att1_twfe, model1_twfe$coefficients[[27]])
  list_att2_twfe <- c(list_att2_twfe, model2_twfe$coefficients[[27]])
  list_att3_twfe <- c(list_att3_twfe, model3_twfe$coefficients[[27]])
  list_att4_twfe <- c(list_att4_twfe, model4_twfe$coefficients[[27]])
  
  list_att1_dcdh <- c(list_att1_dcdh, model1_dcdh$effect[[1]])
  list_att2_dcdh <- c(list_att2_dcdh, model2_dcdh$effect[[1]])
  list_att3_dcdh <- c(list_att3_dcdh, model3_dcdh$effect[[1]])
  list_att4_dcdh <- c(list_att4_dcdh, model4_dcdh$effect[[1]])
}

data_att <- tibble(
  att1Twfe = list_att1_twfe,
  att2Twfe = list_att2_twfe,
  att3Twfe = list_att3_twfe,
  att4Twfe = list_att4_twfe,
  att1Dcdh = list_att1_dcdh,
  att2Dcdh = list_att2_dcdh,
  att3Dcdh = list_att3_dcdh,
  att4Dcdh = list_att4_dcdh
)

write.csv(data_att, "output/simulation_result.csv", row.names = FALSE)

att1_true <- 2.0
att2_true <- 3.8
att3_true <- 0.56
att4_true <- 1.28

att1_est_twfe <- mean(data_att$att1Twfe)
att2_est_twfe <- mean(data_att$att2Twfe)
att3_est_twfe <- mean(data_att$att3Twfe)
att4_est_twfe <- mean(data_att$att4Twfe)

att1_est_dcdh <- mean(data_att$att1Dcdh)
att2_est_dcdh <- mean(data_att$att2Dcdh)
att3_est_dcdh <- mean(data_att$att3Dcdh)
att4_est_dcdh <- mean(data_att$att4Dcdh)

g1 <- data_att |> 
  ggplot() +
  geom_density(aes(x = att1Twfe), fill = "blue", alpha = 0.3) +
  geom_density(aes(x = att1Dcdh), fill = "orange", alpha = 0.3) +
  geom_vline(xintercept = c(att1_true, att1_est_twfe, att1_est_dcdh, 0),
             linetype = "dashed",
             col = c("black", "blue", "orange", "black")) +
  labs(title = "Case1: Staggered + Constant/Equal Treatment Effect",
       x = NULL, y = NULL) +
  xlim(c(min(c(att1_true, att1_est_twfe, att1_est_dcdh)) - 0.3,
         max(c(att1_true, att1_est_twfe, att1_est_dcdh)) + 0.3))

g2 <- data_att |> 
  ggplot() +
  geom_density(aes(x = att2Twfe), fill = "blue", alpha = 0.3) +
  geom_density(aes(x = att2Dcdh), fill = "orange", alpha = 0.3) +
  geom_vline(xintercept = c(att2_true, att2_est_twfe, att2_est_dcdh, 0),
             linetype = "dashed",
             col = c("black", "blue", "orange", "black")) +
  labs(title = "Case2: Staggered + Constant/Unequal Treatment Effect",
       x = NULL, y = NULL) +
  xlim(c(min(c(att2_true, att2_est_twfe, att2_est_dcdh)) - 0.3,
         max(c(att2_true, att2_est_twfe, att2_est_dcdh)) + 0.3))

g3 <- data_att |> 
  ggplot() +
  geom_density(aes(x = att3Twfe), fill = "blue", alpha = 0.3) +
  geom_density(aes(x = att3Dcdh), fill = "orange", alpha = 0.3) +
  geom_vline(xintercept = c(att3_true, att3_est_twfe, att3_est_dcdh, 0),
             linetype = "dashed",
             col = c("black", "blue", "orange", "black")) +
  labs(title = "Case3: Staggered + Dynamic/Equal Treatment Effect",
       x = NULL, y = NULL)+
  xlim(c(min(c(att3_true, att3_est_twfe, att3_est_dcdh)) - 0.3,
         max(c(att3_true, att3_est_twfe, att3_est_dcdh)) + 0.3))

g4 <- data_att |> 
  ggplot() +
  geom_density(aes(x = att4Twfe), fill = "blue", alpha = 0.3) +
  geom_density(aes(x = att4Dcdh), fill = "orange", alpha = 0.3) +
  geom_vline(xintercept = c(att4_true, att4_est_twfe, att4_est_dcdh, 0),
             linetype = "dashed",
             col = c("black", "blue", "orange", "black")) +
  labs(title = "Case4: Staggered + Dynamic/Unqual Treatment Effect",
       x = NULL, y = NULL) +
  xlim(c(min(c(att4_true, att4_est_twfe, att4_est_dcdh)) - 0.3,
         max(c(att4_true, att4_est_twfe, att4_est_dcdh)) + 0.3))

g <- (g1 + g2) / (g3 + g4)
ggsave("figure/fig2.png", g, height = 8, width = 14)