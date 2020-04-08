library(tidyverse)
library(labelled)
library(haven)
library(readr)
library(ech)

ech_2019_iecon <- read_dta("data/ech_2019_iecon.dta") %>% 
  remove_labels() %>% 
  select(bc_correlat, bc_nper, bc_pesoan, bc_nivel, bc_edu, bc_finalizo, bc_rama, 
         bc_tipo_ocup, bc_horas_hab, bc_reg_disse, bc_register, bc_register2, 
         bc_subocupado, bc_subocupado1)

ech_2019 <- readRDS("~/ech_genero/data/ech_2019_raw_ine.rds") %>% 
  left_join(ech_2019_iecon, by = c("numero" = "bc_correlat", "nper" = "bc_nper")) %>% 
  transmute(numero, 
            nper,
            mes,
            depto = dpto, 
            region = region_3, 
            exp_anio = pesoano,
            ingreso_total_hogar = HT11,
            pobre = pobre06,
            indigente = indigente06,
            sexo = e26, 
            edad = e27,
            parentesco = e30,
            cond_actividad = pobpcoac,
            ascendencia = e29_6,
            cat_ocupacion = f73,
            tamanio = f77, 
            lugar_trabajo = f78,
            ingreso_laboral = PT4,
            bc_nivel,
            bc_edu,
            bc_finalizo,
            bc_rama, 
            bc_tipo_ocup,
            bc_reg_disse,
            bc_register,
            bc_register2,
            bc_subocupado, 
            bc_subocupado1,
            horas_trabajadas = f85 + f98,
            estred13) %>% 
  mutate(depto = case_when(
    depto == 1  ~ "Montevideo",
    depto == 2  ~ "Artigas",
    depto == 3  ~ "Canelones",
    depto == 4  ~ "Cerro Largo",
    depto == 5  ~ "Colonia",
    depto == 6  ~ "Durazno",
    depto == 7  ~ "Flores",
    depto == 8  ~ "Florida",
    depto == 9  ~ "Lavalleja",
    depto == 10 ~ "Maldonado",
    depto == 11 ~ "Paysandú",
    depto == 12 ~ "Río Negro",
    depto == 13 ~ "Rivera", 
    depto == 14 ~ "Rocha",
    depto == 15 ~ "Salto",
    depto == 16 ~ "San José",
    depto == 17 ~ "Soriano",
    depto == 18 ~ "Tacuarembó",
    depto == 19 ~ "Treinta y Tres"
  ),
  parentesco = case_when(
    parentesco == 1	 ~ "Jefe/a",
    parentesco == 2	 ~ "Esposo/a o compañero/a",
    parentesco == 3	 ~ "Hijo/a de ambos",
    parentesco == 4	 ~ "Hijo/a sólo del jefe",
    parentesco == 5	 ~ "Hijo/a sólo del esposo/a compañero/a",
    parentesco == 6	 ~ "Yerno/nuera",
    parentesco == 7	 ~ "Padre/madre",
    parentesco == 8	 ~ "Suegro/a",
    parentesco == 9	 ~ "Hermano/a",
    parentesco == 10 ~	"Cuñado/a",
    parentesco == 11 ~	"Nieto/a",
    parentesco == 12 ~	"Otro pariente",
    parentesco == 13 ~	"Otro no pariente",
    parentesco == 14 ~	"Servicio doméstico o familiar del mismo"
  ),
  cond_actividad = case_when(
    cond_actividad == 1	~ "Menores de 14 años",
    cond_actividad == 2	~ "Ocupados",
    cond_actividad == 3	~ "Desocupados buscan trabajo por primera vez",
    cond_actividad == 4	~ "Desocupados propiamente dichos",
    cond_actividad == 5	~ "Desocupados en seguro de paro",
    cond_actividad == 6	~ "Inactivo, realiza quehaceres del hogar",
    cond_actividad == 7	~ "Inactivo, estudiante",
    cond_actividad == 8	~ "Inactivo, rentista",
    cond_actividad == 9	~ "Inactivo, pensionista",
    cond_actividad == 10 ~ "Inactivo, jubilado",
    cond_actividad == 11 ~ "Inactivo, otro"
  ),
  cat_ocupacion = case_when(
    cat_ocupacion == 1 ~ "Asalariado/a privado/a",
    cat_ocupacion == 2 ~ "Asalariado/a público/a",
    cat_ocupacion == 3 ~ "Miembro de cooperativa de producción o trabajo",
    cat_ocupacion == 4 ~ "Patrón/a" ,
    cat_ocupacion == 5 ~ "Cuenta propia sin local ni inversión",
    cat_ocupacion == 6 ~ "Cuenta propia con local o inversión",
    cat_ocupacion == 7 ~ "Miembro del hogar no remunerado",
    cat_ocupacion == 8 ~ "Trabajador/a de un programa social de empleo"
  ),
  region = case_when(
    region == 1 ~ "Montevideo", 
    region == 2 ~ "Interior, localidades de 5000 habitantes o más",
    region == 3 ~ "Interior, localidades de menos de 5000 habitantes y zona rural"
  ),
  pobre = case_when(
    pobre == 0 ~ "No pobre",
    pobre == 1 ~ "Pobre"
  ),
  indigente = case_when(
    indigente == 0 ~ "No indigente",
    indigente == 1 ~ "Indigente"),
  sexo = case_when(
    sexo == 1 ~ "Varón",
    sexo == 2 ~ "Mujer"),
  ascendencia = case_when(
    ascendencia == 1 ~ "Afro o negra",
    ascendencia == 2 ~ "Asiática o amarilla",
    ascendencia == 3 ~ "Blanca",
    ascendencia == 4 ~ "Indígena",
    ascendencia == 5 ~ "Otra"
  ),
  tamanio = case_when(
    tamanio == 1 ~ "Una persona",
    tamanio == 2 ~ "2 a 4 personas",
    tamanio == 3 ~ "5 a 9 personas",
    tamanio == 6 ~ "10 a 19 personas",
    tamanio == 7 ~ "20 a 49 personas",
    tamanio == 5 ~ "50 o más personas"
  ),
  lugar_trabajo = case_when(
    lugar_trabajo == 1 ~ "En un establecimiento fijo",
    lugar_trabajo == 2 ~ "En su vivienda",
    lugar_trabajo == 3 ~ "A domicilio",
    lugar_trabajo == 4 ~ "En la calle, en un puesto o lugar fijo",
    lugar_trabajo == 5 ~ "En la calle, en un puesto móvil",
    lugar_trabajo == 6 ~ "En la calle, desplazándose",
    lugar_trabajo == 7 ~ "En la vía pública",
    lugar_trabajo == 8 ~ "En un predio agropecuario o marítimo"
  ),
  bc_nivel = case_when(
   bc_nivel == 0 ~ "Sin instrucción",
   bc_nivel == 1 ~ "Primaria",
   bc_nivel == 2 ~ "Secundaria",
   bc_nivel == 3 ~ "Enseñanza técnica o UTU",
   bc_nivel == 4 ~ "Magisterio o Profesorado",
   bc_nivel == 5 ~ "Universidad o similar"
  ),
  bc_nivel = factor(bc_nivel, levels = c("Sin instrucción", "Primaria", "Secundaria", "Enseñanza técnica o UTU",
                                         "Magisterio o Profesorado", "Universidad o similar")),
  bc_finalizo = case_when(
    bc_finalizo == 1  ~ "Si",
    bc_finalizo == 2  ~ "No"
  ),
  bc_rama = case_when(
    bc_rama == 1 ~ "Agropecuaria y Minería",
    bc_rama == 2 ~ "Industria Manufactureras",
    bc_rama == 3 ~ "Electricidad, Gas y Agua",
    bc_rama == 4 ~ "Construcción",
    bc_rama == 5 ~ "Comercio, Restaurantes y Hoteles",
    bc_rama == 6 ~ "Transportes y Comunicaciones",
    bc_rama == 7 ~ "Servicios a empresas",
    bc_rama == 8 ~ "Servicios comunales, sociales y personales"
  ),
  bc_tipo_ocup = case_when(
    bc_tipo_ocup == 0	~ "Fuerzas Armadas",
    bc_tipo_ocup == 1	~ "Miembro de poder ejecutivo y cuerpos legislativos y personal directivo de la administración pública y de las empresas",
    bc_tipo_ocup == 2	~ "Profesionales científicos e intelectuales",
    bc_tipo_ocup == 3	~ "Técnicos y profesionales de nivel medio",
    bc_tipo_ocup == 4	~ "Empleados de oficina",
    bc_tipo_ocup == 5	~ "Trabajadores de los servicios y vendedores de comercios y mercados",
    bc_tipo_ocup == 6	~ "Agricultores y trabajadores calificados agropecuarios y pesqueros",
    bc_tipo_ocup == 7	~ "Oficiales, operarios y artesanos de artes mecánicas y de otros oficios",
    bc_tipo_ocup == 8	~ "Operadores y montadores de instalaciones y máquinas",
    bc_tipo_ocup == 9	~ "Trabajadores no calificados"
  ),
  bc_reg_disse = case_when(
    bc_reg_disse == 1  ~ "Si",
    bc_reg_disse == 2  ~ "No" 
  ),
  bc_register = case_when(
    bc_register == 1  ~ "Si",
    bc_register == 2  ~ "No" 
  ),
  bc_register2 = case_when(
    bc_register2 == 1  ~ "Si",
    bc_register2 == 2  ~ "No" 
  ),
  bc_subocupado = case_when(
    bc_subocupado == 1  ~ "Si",
    bc_subocupado == 2  ~ "No" 
  ), 
  bc_subocupado1 = case_when(
    bc_subocupado1 == 1  ~ "Si",
    bc_subocupado1 == 2  ~ "No" 
  ),
  ipc = case_when(
    mes == 1 ~  100.00,
    mes == 2 ~  100.98,
    mes == 3 ~  101.53,
    mes == 4 ~  101.97,
    mes == 5 ~  102.37,
    mes == 6 ~  103.03,
    mes == 7 ~  103.81,
    mes == 8 ~  104.73,
    mes == 9 ~  105.27,
    mes == 10 ~ 106.06,
    mes == 11 ~ 106.51,
    mes == 12 ~ 106.48,
  ),
  ingreso_total_hogar_deflactado = (ingreso_total_hogar/ipc)*100,
  ingreso_laboral_deflactado = (ingreso_laboral/ipc)*100,
  ingreso_por_hora = ingreso_laboral_deflactado/horas_trabajadas,
  ingreso_por_hora = ifelse(is.nan(ingreso_por_hora), NA_integer_, ingreso_por_hora),
  grupo_etario = case_when(
    (edad > 17 & edad < 26) ~ "18-25 años",
    (edad > 25 & edad < 36) ~ "26-35 años",
    (edad > 35 & edad < 51) ~ "36-50 años",
    (edad > 50 & edad < 66) ~ "51-65 años",
    T ~ NA_character_
  ),
  grupo_etario = factor(grupo_etario, levels = c("18-25 años", "26-35 años", "36-50 años",
                                                 "51-65 años"))) %>% 
  group_by(numero) %>% 
  mutate(menores = ifelse(any(edad, na.rm = T) < 18, T, F),
         hijos = ifelse(any(parentesco == "Hijo/a de ambos") |
                          any(parentesco == "Hijo/a sólo del jefe") |
                          any(parentesco == "Hijo/a sólo del esposo/a compañero/a"), T, F)) %>% 
  ungroup() %>% 
  mutate(hijos_menores = ifelse(menores == T & hijos == T, "Si", "No"))

write_rds(ech_2019, "data/ech_2019.rds")  



