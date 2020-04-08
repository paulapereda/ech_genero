library(hrbrthemes)
library(tidyverse)
library(survey)
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

### Excluyo al 99% más rico:

ech_2019 %>% 
  srvyr::as_survey_design(ids = 1, strata = estred13, weights = exp_anio) %>%
  summarise(percentil = srvyr::survey_quantile(ingreso_laboral_deflactado, c(0.99)))

ech_2019 %>%
  filter(!is.na(grupo_etario)) %>% 
  filter(cond_actividad == "Ocupados" & ingreso_laboral_deflactado < 117630) %>% 
  ggplot(aes(ingreso_laboral_deflactado, weight = exp_anio, color = sexo, fill = sexo)) +
  geom_density(adjust = 1.5, alpha = .7) +
  scale_fill_manual(values = c("Varón" = "#58c1aa", "Mujer" = "#7c2ef0")) +
  scale_color_manual(values = c("Varón" = "#58c1aa", "Mujer" = "#7c2ef0")) +
  xlab("Ingresos laborales ($)") +
  scale_x_continuous(labels = scales::number_format(big.mark = ".")) +
  ylab("Densidad") + 
  lemon::facet_rep_grid(vars(sexo), repeat.tick.labels = TRUE) +
  labs(title = "Distribución de los ingresos laborales según sexo (2019)", 
               caption = "Fuente: elaboración propia en base a ECH 2019.
               Paula Pereda - @paubgood") +
  theme_ipsum() +
  theme(legend.title = element_blank(),
        legend.position = "none",
        axis.text.y = element_blank()) +
  ggsave("plots/distribucion_salarial_sexo.png", dpi = 550)

# 3) Brecha salarial por edad

ech_2019 %>% 
  filter(cond_actividad == "Ocupados" & !is.na(grupo_etario)) %>% 
  group_by(sexo, grupo_etario) %>% 
  summarise(mean = sum(ingreso_laboral_deflactado*exp_anio, na.rm = T)/sum(exp_anio, na.rm = T)) %>% 
  spread(sexo, mean) %>% 
  mutate(Brecha = paste0(round((1 - Mujer/Varón)*100), "%")) %>% 
  pivot_longer(cols = Mujer:Varón, names_to = c("Sexo"), values_to = "ingresos_salariales") %>% 
  ggplot(aes(grupo_etario, ingresos_salariales, fill = Sexo, label = Brecha)) +
  geom_col(position = "dodge", alpha = .7) +  
  scale_fill_manual(values = c("Varón" = "#58c1aa", "Mujer" = "#7c2ef0")) +
  ylab("Ingresos laborales ($)") +
  scale_y_continuous(labels = scales::number_format(big.mark = ".")) +
  xlab("") + 
  labs(title = "Brecha salarial según grupo etario (2019)", 
       caption = "Fuente: elaboración propia en base a ECH 2019.
                 Paula Pereda - @paubgood") +
  annotate("text", x = "18-25 años", y = 20501, label = "Brecha: 13%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = "26-35 años", y = 34497, label = "Brecha: 19%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = "36-50 años", y = 42833, label = "Brecha: 24%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = "51-65 años", y = 45074, label = "Brecha: 27%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  theme_ipsum() +
  theme(legend.position = "none",
        axis.title.y = element_text(angle = 0)) +
  ggsave("plots/brecha_salarial_edad.png", dpi = 550)

# 3) Brecha salarial por nivel de instrucción

ech_2019 %>% 
  filter(cond_actividad == "Ocupados" & !is.na(grupo_etario) & !is.na(bc_nivel)) %>% 
  group_by(sexo, bc_nivel) %>% 
  summarise(mean = sum(ingreso_laboral_deflactado*exp_anio, na.rm = T)/sum(exp_anio, na.rm = T)) %>% 
  spread(sexo, mean) %>% 
  mutate(Brecha = paste0(round((1 - Mujer/Varón)*100), "%")) %>% 
  pivot_longer(cols = Mujer:Varón, names_to = c("Sexo"), values_to = "ingresos_salariales") %>% 
  ggplot(aes(bc_nivel, ingresos_salariales, fill = Sexo, label = Brecha)) +
  geom_col(position = "dodge", alpha = .7) +  
  scale_fill_manual(values = c("Varón" = "#58c1aa", "Mujer" = "#7c2ef0")) +
  ylab("Ingresos laborales ($)") +
  scale_y_continuous(labels = scales::number_format(big.mark = ".")) +
  xlab("") + 
  labs(title = "Brecha salarial según nivel educativo (2019)", 
       caption = "Fuente: elaboración propia en base a ECH 2019.
                 Paula Pereda - @paubgood") +
  annotate("text", x = "Sin instrucción", y = 25353, label = "Brecha: 53%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = "Primaria", y = 26174, label = "Brecha: 41%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = "Secundaria", y = 33518, label = "Brecha: 33%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = "Enseñanza técnica o UTU", y = 37937, label = "Brecha: 27%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = "Magisterio o Profesorado", y = 42850, label = "Brecha: 7%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = "Universidad o similar", y = 64888, label = "Brecha: 28%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  theme_ipsum() +
  theme(legend.position = "none",
        axis.title.y = element_text(angle = 0)) +
  ggsave("plots/brecha_salarial_educ.png", dpi = 550, width = 12)

# 4) Brecha salarial según presencia de hijos menores

ech_2019 %>% 
  filter(cond_actividad == "Ocupados" & !is.na(grupo_etario)) %>% 
  mutate(hijos_menores = case_when(
    hijos_menores == "Si" ~ "Hogares con hijos menores",
    hijos_menores == "No" ~ "Hogares sin hijos menores",
  )) %>% 
  group_by(sexo, hijos_menores) %>% 
  summarise(mean = sum(ingreso_laboral_deflactado*exp_anio, na.rm = T)/sum(exp_anio, na.rm = T)) %>% 
  spread(sexo, mean) %>% 
  mutate(Brecha = paste0(round((1 - Mujer/Varón)*100), "%")) %>% 
  pivot_longer(cols = Mujer:Varón, names_to = c("Sexo"), values_to = "ingresos_salariales") %>% 
  ggplot(aes(hijos_menores, ingresos_salariales, fill = Sexo, label = Brecha)) +
  geom_col(position = "dodge", alpha = .7) +  
  scale_fill_manual(values = c("Varón" = "#58c1aa", "Mujer" = "#7c2ef0")) +
  ylab("Ingresos laborales ($)") +
  scale_y_continuous(labels = scales::number_format(big.mark = ".")) +
  xlab("") + 
  labs(title = "Brecha salarial según presencia de hijos menores en el hogar (2019)", 
       caption = "Fuente: elaboración propia en base a ECH 2019.
                 Paula Pereda - @paubgood") +
  annotate("text", x = "Hogares con hijos menores", y = 37562, label = "Brecha: 23%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = "Hogares sin hijos menores", y = 39220, label = "Brecha: 17%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  theme_ipsum() +
  theme(legend.position = "none",
        axis.title.y = element_text(angle = 0)) +
  ggsave("plots/brecha_salarial_hijos.png", dpi = 550, width = 10)

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

# haven::read_dta("data/p17.dta", col_select = c(bc_pesoan, bc_pe2, bc_pobp, bc_ing_lab, bc_nivel)) %>%
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
#             bc_nivel = case_when(
#               bc_nivel == 0 ~ "Sin instrucción",
#               bc_nivel == 1 ~ "Primaria",
#               bc_nivel == 2 ~ "Secundaria",
#               bc_nivel == 3 ~ "Enseñanza técnica o UTU",
#               bc_nivel == 4 ~ "Magisterio o Profesorado",
#               bc_nivel == 5 ~ "Universidad o similar"
#             ),
#             ingreso_laboral_deflactado = bc_ing_lab) %>%
#   filter(cond_actividad == "Ocupados") %>%
#   group_by(sexo, bc_nivel) %>%
#   summarise(mean = sum(ingreso_laboral_deflactado*exp_anio, na.rm = T)/sum(exp_anio, na.rm = T)) %>%
#   spread(sexo, mean)  %>% 
#   mutate(Brecha = 1 - Mujer/Varón)
