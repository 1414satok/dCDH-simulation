library(dplyr)
library(tidyverse)
library(patchwork)
library(DIDmultiplegt)
source("code/gen_data.R")

## get ATT in time series by bootstrap

set.seed(1414)

n_obs <- 1000
total_years <- 36
n_bs <- 20 # the number of bootstrap
sig_level <- 0.95

data <- make_simulation(n_obs, total_years)

list_lag <- rep(-5:5, 20)

list_effect_twfe <- c()
list_effect_dcdh <- c()

for(j in 1:n_bs){
  sample_id <- sample(1:n_obs, n_obs, replace = TRUE) - 1
  bs_index <- rep(sample_id, each = total_years) * 36 + rep(1:total_years, time = n_obs)
  data_bssample <- data[bs_index,]
  
  model4_twfe <- data_bssample |> 
    mutate(timeToTreatment = year - trTime) |>
    feols(
      y4 ~ i(timeToTreatment, ref = -1) |
        id + year, 
      data = _
    )
  model4_dcdh <- did_multiplegt(df = data_bssample, Y = "y4", G = "id", T = "year", D = "isTreated",
                                dynamic = 5, placebo = 5)
  
  list_effect_twfe <- c(list_effect_twfe,
                        sapply(23:26, function(i){model4_twfe$coefficients[[i]]}),
                        0,
                        sapply(27:32, function(i){model4_twfe$coefficients[[i]]}))
  list_effect_dcdh <- c(list_effect_dcdh,
                        sapply(c(seq(27, 19, -2), 1, seq(4, 16, 3)), function(i){model4_dcdh[[i]][[1]]}))
  print(j)
}

data_lagged_effect <- tibble(
  lag = list_lag,
  laggedEffectTwfe = list_effect_twfe,
  laggedEffectDcdh = list_effect_dcdh
) |> 
  group_by(lag) |> 
  summarise(
    attTwfe = mean(laggedEffectTwfe),
    seTwfe = sqrt(var(laggedEffectTwfe)),
    attDcdh = mean(laggedEffectDcdh),
    seDcdh = sqrt(var(laggedEffectDcdh))
  ) |> 
  mutate(
    uciTwfe = attTwfe - qnorm((1 - sig_level)/2) * seTwfe,
    lciTwfe = attTwfe + qnorm((1 - sig_level)/2) * seTwfe,
    uciDcdh = attDcdh - qnorm((1 - sig_level)/2) * seDcdh,
    lciDcdh = attDcdh + qnorm((1 - sig_level)/2) * seDcdh
  ) |> 
  cbind(tibble(trueEffect = c(rep(0, 5), sapply(0:5, function(i){(6.4 + 1.9 * i)/5}))))

write.csv(data_lagged_effect, "output/lagged_effect.csv", row.names = FALSE)

g1 <- data_lagged_effect |> 
  ggplot() +
  geom_point(aes(x = lag, y = attTwfe)) +
  geom_line(aes(x = lag, y = attTwfe)) +
  geom_line(aes(x = lag, y = trueEffect), color = "orange") +
  geom_errorbar(aes(x = lag, ymin = lciTwfe, ymax = uciTwfe)) +
  labs(y = "ATT of TWFE", title = "ATT in Timeseries (Case 4)")

g2 <- data_lagged_effect |> 
  ggplot() +
  geom_point(aes(x = lag, y = attDcdh)) +
  geom_line(aes(x = lag, y = attDcdh)) +
  geom_line(aes(x = lag, y = trueEffect), color = "orange") +
  geom_errorbar(aes(x = lag, ymin = lciDcdh, ymax = uciDcdh)) +
  labs(y = "ATT of dCDH")

g <- (g1 + g2)
ggsave("figure/fig3.png", g, width = 14, height = 8)