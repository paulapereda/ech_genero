ech_2019 %>% 
  filter(cond_actividad == "Ocupados") %>% 
  group_by(sexo) %>% 
  summarise(mean = mean(ingreso_laboral_deflactado)) %>%
  spread(sexo, mean) %>%
  mutate(Brecha = 1 - Mujer/Hombre)

ech_2019 %>%
  filter(cond_actividad == "Ocupados") %>%
  group_by(sexo, ascendencia) %>% 
  summarise(mean = mean(ingreso_por_hora)) %>%
  spread(sexo, mean) %>% 
  mutate(Brecha = 1 - Mujer/Hombre)

ech_2019 %>%
  filter(cond_actividad == "Ocupados") %>%
  group_by(sexo, bc_nivel) %>% 
  summarise(mean = mean(ingreso_por_hora)) %>%
  spread(sexo, mean) %>% 
  mutate(Brecha = 1 - Mujer/Hombre)

