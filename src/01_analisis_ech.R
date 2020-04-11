library(hrbrthemes)
library(tidyverse)
library(readxl)
library(readr)

ech_2019 <- read_rds("data/ech_2019.rds") 

# 0) Tasa de actividad, empleo y desempleo

ech_2019 %>% 
    group_by(sexo) %>%
    summarise(tasa_actividad = (sum(pea*exp_anio)/sum(pet*exp_anio))*100,
              tasa_empleo = (sum(po*exp_anio)/sum(pet*exp_anio))*100,
              tasa_desempleo = (sum(pd*exp_anio)/sum(pea*exp_anio))*100) %>% 
  pivot_longer(cols = starts_with("tasa"), names_to = "Tasa", values_to = "Valor") %>% 
  spread(sexo, Valor) %>% 
  mutate(Tasa = factor(Tasa, levels = c("tasa_desempleo", "tasa_empleo", "tasa_actividad")),
         Tasa = plyr::revalue(Tasa,  c("tasa_actividad" = 1, 
                                       "tasa_empleo" = 2, 
                                       "tasa_desempleo" = 3))) %>% 
  ggplot(aes()) +
  geom_segment(aes(x = Tasa, xend = Tasa, y = Mujer, yend = Varón), color = "#cccccc", size = 1) +
  geom_point(aes(x = Tasa, y = Mujer), color = "#7c2ef0", size = 3) +
  geom_point(aes(x = Tasa, y = Varón), color = "#58c1aa", size = 3) +
  scale_x_discrete(labels = c("Tasa de desempleo", "Tasa de empleo", "Tasa de actividad")) +
  coord_flip() +
  ylab("Tasa (%)") +
  xlab("") +
  annotate("text", x = 2.85, y = 55, label = "55%", color = "#7c2ef0", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = 2.85, y = 70.2, label = "70%", color = "#58c1aa", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = 0.85, y = 10.8, label = "11%", color = "#7c2ef0", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = 0.85, y = 7.43, label = "7%", color = "#58c1aa", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = 1.85, y = 49.2, label = "49%", color = "#7c2ef0", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = 1.85, y = 65.1, label = "65%", color = "#58c1aa", fontface = "bold", family = "Arial Narrow") +
  labs(title = "Tasa de actividad, empleo y desempleo según sexo: mujeres y varones (2019)", 
       caption = "Fuente: elaboración propia en base a ECH 2019.
                  Paula Pereda - @paubgood") +
  theme_ipsum() +
  ggsave("plots/tasas_sexo.png", dpi = 550, width = 10)

# 1) Evolución de los ingresos salariales por sexo (IECON - ECH compatibilizadas)

ech_evolucion <- read_xlsx("data/evolucion_ingresos_salariales.xlsx") 

# Para llegar al .xlsx anterior corrí el siguiente código para el período 2006-2018 ("p6.dta",
# "p7.dta", ..., "p18.dta") con las bases compatibilizadas por el IECON - FCEA, UdelaR. 

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

ech_evolucion %>% 
  ggplot(aes(Año, total_ingresos_laborales, group = Sexo, color = Sexo)) +
  geom_line() +
  geom_point() +
  xlab("") +
  scale_color_manual(values = c("Varón" = "#58c1aa", "Mujer" = "#7c2ef0")) +
  scale_x_continuous(breaks = c(2006, 2008, 2010, 2012, 2014, 2016, 2018)) +
  ylab("Ingresos \nmedios ($)") +
  scale_y_continuous(labels = scales::number_format(big.mark = ".")) +
  labs(title = "La brecha salarial según sexo: mujeres y varones (2006 - 2018)", 
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
  geom_text(aes(label = paste("22%"), x = 2018, y = (13238+10514)/ 2), inherit.aes = FALSE, color = "#2b2b2b", family = "Arial Narrow", size = 3) +
  ggsave("plots/evolucion_ingreso_laboral_sexo.png", dpi = 550, width = 10)

ech_evolucion %>% 
  spread(Sexo, total_ingresos_laborales) %>% 
  mutate(Brecha = (1 - (Mujer/Varón))*100) %>% 
  ggplot(aes(Año, Brecha)) +
  geom_line(color = "#7c2ef0") +
  geom_point(color = "#7c2ef0") +
  xlab("") +
  scale_y_continuous(limits = c(0, 35)) +
  scale_x_continuous(breaks = c(2006, 2008, 2010, 2012, 2014, 2016, 2018)) +
  ylab("Brecha salarial \npor sexo (%)") +
  labs(title = "Evolución de la brecha salarial en Uruguay (2006 - 2018)", 
       caption = "Fuente: elaboración propia en base a ECH compatibilizadas (IECON - FCEA, UdelaR)
       Paula Pereda - @paubgood") +
  theme_ipsum() +
  theme(axis.title.y = element_text(angle = 0)) +
  ggsave("plots/evolucion_brecha_salarial_sexo.png", dpi = 550, width = 10)

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
  labs(title = "Distribución de los ingresos laborales según sexo: mujeres y varones (2019)", 
               caption = "Fuente: elaboración propia en base a ECH 2019.
               Paula Pereda - @paubgood") +
  theme_ipsum() +
  theme(legend.title = element_blank(),
        legend.position = "none",
        axis.text.y = element_blank()) +
  ggsave("plots/distribucion_salarial_sexo.png", dpi = 550, width = 10)

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
  labs(title = "Brecha salarial según grupo etario y sexo: mujeres y varones (2019)", 
       caption = "Fuente: elaboración propia en base a ECH 2019.
                 Paula Pereda - @paubgood") +
  annotate("text", x = "18-25 años", y = 20501, label = "Brecha: 13%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = "26-35 años", y = 34497, label = "Brecha: 19%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = "36-50 años", y = 42833, label = "Brecha: 24%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = "51-65 años", y = 45074, label = "Brecha: 27%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  theme_ipsum() +
  theme(legend.position = "none",
        axis.title.y = element_text(angle = 0)) +
  ggsave("plots/brecha_salarial_edad.png", dpi = 550, width = 10)

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
  labs(title = "Brecha salarial según nivel educativo y sexo: mujeres y varones (2019)", 
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
  labs(title = "Brecha salarial según presencia de hijos menores en el hogar y \nsexo: mujeres y varones (2019)", 
       caption = "Fuente: elaboración propia en base a ECH 2019.
                 Paula Pereda - @paubgood") +
  annotate("text", x = "Hogares con hijos menores", y = 40288, label = "Brecha: 27%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  annotate("text", x = "Hogares sin hijos menores", y = 34991, label = "Brecha: 15%", color = "#2b2b2b", fontface = "bold", family = "Arial Narrow") +
  theme_ipsum() +
  theme(legend.position = "none",
        axis.title.y = element_text(angle = 0)) +
  ggsave("plots/brecha_salarial_hijos.png", dpi = 550, width = 10)

# 5) Evolución: tasa de actividad, empleo y desempleo

ech_evolucion_tasas <- read_xlsx("data/evolucion_tasas.xlsx") %>% 
  mutate(label = paste0(round(Valor), "%"))

# Para llegar al .xlsx anterior corrí el siguiente código para el período 2006-2018 ("p6.dta",
# "p7.dta", ..., "p18.dta") con las bases compatibilizadas por el IECON - FCEA, UdelaR. 

# haven::read_dta("data/p18.dta", col_select = c(bc_anio, bc_pesoan, bc_pe2, bc_pobp)) %>%
#   labelled::remove_labels() %>% 
#   filter(!is.na(bc_pesoan)) %>% 
#   mutate(pea = ifelse(bc_pobp %in% 2:5, 1, 0),
#          pet = ifelse(bc_pobp != 1, 1, 0),
#          po = ifelse(bc_pobp == 2, 1, 0),
#          pd = ifelse(bc_pobp %in% 3:5, 1, 0)) %>% 
#   transmute(Año = bc_anio,
#             exp_anio = bc_pesoan,
#             pea,
#             pet,
#             po,
#             pd,
#             sexo = case_when(
#               bc_pe2 == 1 ~ "Varón",
#               bc_pe2 == 2 ~ "Mujer"),
#             sexo = factor(sexo, levels = c("Varón", "Mujer"))) %>%
#   group_by(sexo, Año) %>%
#   summarise(tasa_actividad = (sum(pea*exp_anio)/sum(pet*exp_anio))*100,
#             tasa_empleo = (sum(po*exp_anio)/sum(pet*exp_anio))*100,
#             tasa_desempleo = (sum(pd*exp_anio)/sum(pea*exp_anio))*100) %>% 
#   pivot_longer(cols = starts_with("tasa"), names_to = "Tasa", values_to = "Valor") %>% 
#   mutate(label = paste0(round(Valor), "%")) 

ech_evolucion_tasas %>% 
  filter(Tasa == "tasa_actividad") %>% 
  ggplot(aes(Año, Valor, group = sexo, color = sexo, label = label)) +
  geom_line() +
  geom_point() +
  geom_text(vjust = 0, nudge_y = 0.5, color = "#2b2b2b", family = "Arial Narrow", size = 3) +
  scale_color_manual(values = c("Varón" = "#58c1aa", "Mujer" = "#7c2ef0")) +
  scale_x_continuous(breaks = c(2006, 2008, 2010, 2012, 2014, 2016, 2018)) +
  xlab("") +
  ylab("Tasa de \nactividad (%)") +
  labs(title = "Evolución de la tasa de actividad según sexo: mujeres y varones (2006 - 2018)", 
       caption = "Fuente: elaboración propia en base a ECH compatibilizadas (IECON - FCEA, UdelaR)
                 Paula Pereda - @paubgood") +
  theme_ipsum() +
  theme(legend.position = "none",
        axis.title.y = element_text(angle = 0)) +
  ggsave("plots/evolucion_ta.png", dpi = 550, width = 10)

ech_evolucion_tasas %>% 
  filter(Tasa == "tasa_empleo") %>% 
  ggplot(aes(Año, Valor, group = sexo, color = sexo, label = label)) +
  geom_line() +
  geom_point() +
  geom_text(vjust = 0, nudge_y = 0.5, color = "#2b2b2b", family = "Arial Narrow", size = 3) +
  scale_color_manual(values = c("Varón" = "#58c1aa", "Mujer" = "#7c2ef0")) +
  scale_x_continuous(breaks = c(2006, 2008, 2010, 2012, 2014, 2016, 2018)) +
  xlab("") +
  ylab("Tasa de \nempleo (%)") +
  labs(title = "Evolución de la tasa de empleo según sexo: mujeres y varones (2006 - 2018)", 
       caption = "Fuente: elaboración propia en base a ECH compatibilizadas (IECON - FCEA, UdelaR)
                 Paula Pereda - @paubgood") +
  theme_ipsum() +
  theme(legend.position = "none",
        axis.title.y = element_text(angle = 0)) +
  ggsave("plots/evolucion_te.png", dpi = 550, width = 10)

ech_evolucion_tasas %>% 
  filter(Tasa == "tasa_desempleo") %>% 
  ggplot(aes(Año, Valor, group = sexo, color = sexo, label = label)) +
  geom_line() +
  geom_point() +
  geom_text(vjust = 0, nudge_y = 0.5, color = "#2b2b2b", family = "Arial Narrow", size = 3) +
  scale_color_manual(values = c("Varón" = "#58c1aa", "Mujer" = "#7c2ef0")) +
  scale_x_continuous(breaks = c(2006, 2008, 2010, 2012, 2014, 2016, 2018)) +
  scale_y_continuous(limits = c(0, 15)) +
  xlab("") +
  ylab("Tasa de \ndesempleo (%)") +
  labs(title = "Evolución de la tasa de desempleo según sexo: mujeres y varones (2006 - 2018)", 
       caption = "Fuente: elaboración propia en base a ECH compatibilizadas (IECON - FCEA, UdelaR)
                 Paula Pereda - @paubgood") +
  theme_ipsum() +
  theme(legend.position = "none",
        axis.title.y = element_text(angle = 0)) +
  ggsave("plots/evolucion_td.png", dpi = 550, width = 10)

# Extras:

## Tasas por departamento:

ech_2019 %>% 
  group_by(sexo, depto) %>%
  summarise(tasa_actividad = (sum(pea*exp_anio)/sum(pet*exp_anio))*100,
            tasa_empleo = (sum(po*exp_anio)/sum(pet*exp_anio))*100,
            tasa_desempleo = (sum(pd*exp_anio)/sum(pea*exp_anio))*100) %>% 
  pivot_longer(cols = starts_with("tasa"), names_to = "Tasa", values_to = "Valor") %>% 
  spread(Tasa, Valor) %>% 
  arrange(depto, sexo) %>% 
  transmute(Departamento = depto,
            Sexo = sexo, 
            "Tasa de actividad" = paste0(round(tasa_actividad), "%"),
            "Tasa de empleo" = paste0(round(tasa_empleo), "%"),
            "Tasa de desempleo" = paste0(round(tasa_desempleo), "%")) 