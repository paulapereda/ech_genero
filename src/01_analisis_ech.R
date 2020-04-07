library(hrbrthemes)
library(tidyverse)
library(readxl)
library(readr)

ech_2019 <- read_rds("data/ech_2019.rds") 

# 1) Evolución de los ingresos salariales por sexo (IECON - ECH compatibilizadas)

ech_evolucion <- read_xlsx("data/evolucion_ingresos_salariales.xlsx") 

ech_evolucion %>% 
  ggplot(aes(Año, total_ingresos_laborales, group = Sexo, color = Sexo)) +
  geom_line() +
  geom_point() +
  xlab("") +
  scale_color_manual(values = c("Varón" = "#58c1aa", "Mujer" = "#7c2ef0")) +
  scale_x_continuous(breaks = c(2006, 2008, 2010, 2012, 2014, 2016, 2018)) +
  ylab("Ingresos \nmedios ($)") +
  scale_y_continuous(labels = scales::number_format(big.mark = ".")) +
  labs(title = "La brecha salarial en Uruguay (2006 - 2018)", 
       subtitle = "Los ingresos laborales están expresados a precios constantes de diciembre 2006.",
       caption = "Fuente: elaboración propia en base a ECH compatibilizadas (IECON - FCEA, UdelaR)
       Paula Pereda - @paubgood") +
  theme_ipsum() +
  theme(legend.title = element_blank(),
        legend.position = "none",
        axis.title.y = element_text(angle = 0)) +
  annotate("text", x = 2017, y = 10000, label = "Mujeres", color = "#7c2ef0", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = 2015, y = 13800, label = "Varones", color = "#58c1aa", fontface = "bold", family = "Arial Narrow") +
  geom_segment(aes(x = 2018, xend = 2018, y = 13238, yend = 12050), inherit.aes = FALSE, color = "#cccccc") +
  geom_segment(aes(x = 2018, xend = 2018, y = 10514, yend = 11700), inherit.aes = FALSE, color = "#cccccc") +
  geom_text(aes(label = paste("23%"), x = 2018, y = (13238+10514)/ 2), inherit.aes = FALSE, color = "#2b2b2b", family = "Arial Narrow", size = 3) +
  ggsave("plots/evolucion_ingreso_laboral_sexo.png", dpi = 550)

ech_evolucion %>% 
  spread(Sexo, total_ingresos_laborales) %>% 
  mutate(Brecha = (1 - (Mujer/Varón))*100) %>% 
  ggplot(aes(Año, Brecha)) +
  geom_line(color = "#7c2ef0") +
  geom_point(color = "#7c2ef0") +
  xlab("") +
  scale_y_continuous(limits = c(0, 35))+
  scale_x_continuous(breaks = c(2006, 2008, 2010, 2012, 2014, 2016, 2018)) +
  ylab("Brecha salarial \npor sexo (%)") +
  labs(title = "Evolución de la brecha salarial en Uruguay (2006 - 2018)", 
       caption = "Fuente: elaboración propia en base a ECH compatibilizadas (IECON - FCEA, UdelaR)
       Paula Pereda - @paubgood") +
  theme_ipsum() +
  theme(axis.title.y = element_text(angle = 0)) +
  ggsave("plots/evolucion_brecha_salarial_sexo.png", dpi = 550)

# 2)  Distribución de ingresos por sexo



  


ech_2019 %>% 
  dplyr::filter(cond_actividad == "Ocupados") %>% 
  group_by(sexo) %>% 
  summarise(mean = sum(ingreso_laboral_deflactado*exp_anio, na.rm = T)/sum(exp_anio, na.rm = T)) %>%
  spread(sexo, mean) %>%
  mutate(Brecha = (1 - Mujer/Hombre)*100)

ech_2019 %>%
  filter(cond_actividad == "Ocupados") %>%
  group_by(sexo, bc_rama) %>% 
  summarise(mean = mean(ingreso_por_hora*exp_anio)) %>%
  spread(sexo, mean) %>% 
  mutate(Brecha = 1 - Mujer/Hombre)

ech_2019 %>%
  filter(cond_actividad == "Ocupados") %>%
  group_by(sexo, bc_nivel) %>% 
  summarise(mean = mean(ingreso_por_hora*exp_anio)) %>%
  spread(sexo, mean) %>% 
  mutate(Brecha = 1 - Mujer/Hombre)

####### Cógido comentado

# ech_srvyr <- ech_2019 %>% 
#   as_survey_design(ids = 1, strata = estred13, weights = exp_anio)
# 
# ech_srvyr %>%
#   filter(cond_actividad == "Ocupados") %>% 
#   filter(!is.na(horas_trabajadas)) %>% 
#   group_by(sexo) %>%
#   summarize(proportion = survey_mean(ingreso_laboral_deflactado)) %>% 
#   select(- ends_with("se")) %>% 
#   spread(sexo, proportion) %>% 
#   mutate(Brecha = 1 - Mujer/Hombre)

# 1) Evolución de los ingresos salariales por sexo

# haven::read_dta("data/p18.dta", col_select = c(bc_pesoan, bc_pe2, bc_pobp, bc_ing_lab)) %>% 
#   transmute(exp_anio = bc_pesoan,
#             sexo = case_when(
#               bc_pe2 == 1 ~ "Varón",
#               bc_pe2 == 2 ~ "Mujer"),
#             sexo = factor(sexo, levels = c("Varón", "Mujer")),
#             cond_actividad = case_when(
#               bc_pobp == 1	~ "Menores de 14 años",
#               bc_pobp == 2	~ "Ocupados",
#               bc_pobp == 3	~ "Desocupados buscan trabajo por primera vez",
#               bc_pobp == 4	~ "Desocupados propiamente dichos",
#               bc_pobp == 5	~ "Desocupados en seguro de paro",
#               bc_pobp == 6	~ "Inactivo, realiza quehaceres del hogar",
#               bc_pobp == 7	~ "Inactivo, estudiante",
#               bc_pobp == 8	~ "Inactivo, rentista",
#               bc_pobp == 9	~ "Inactivo, pensionista",
#               bc_pobp == 10 ~ "Inactivo, jubilado",
#               bc_pobp == 11 ~ "Inactivo, otro"),
#             ingreso_laboral_deflactado = bc_ing_lab) %>% 
#   filter(cond_actividad == "Ocupados") %>% 
#   group_by(sexo) %>% 
#   summarise(mean = sum(ingreso_laboral_deflactado*exp_anio, na.rm = T)/sum(exp_anio, na.rm = T)) 
