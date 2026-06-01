
##### 1. Análisis de Componentes Principales (PCA) #####

# 1. Leemos el archivo CSV
datos_w <- read.csv("mis_vectores_stylegan (3).csv")

# 2. Dimensiones de nuestra tabla
dim(datos_w)

# 3. Echamos un vistazo a las primeras filas y columnas (para comprobar)
head(datos_w[, 1:5])

# Usamos center=TRUE para centrar los datos, y scale=FALSE porque 
# todas las variables del espacio latente ya están en la misma escala.
pca_result <- prcomp(datos_w, center = TRUE, scale. = FALSE)



# Extraemos la primera componente principal o PC1
# Esto es un vector de 512 números que representa el cambio más grande
direccion_pca1 <- pca_result$rotation[, 1] # como queremos la PC1 cogemos la primera colunna

# Segundo componente principal o PC2
direccion_pca2 <- pca_result$rotation[, 2]

direccion_pca3 <- pca_result$rotation[, 3]

# Guardamos los vectores para usarlos en Colab
write.csv(as.data.frame(direccion_pca1), "direccion_pca11.csv", row.names = FALSE)
write.csv(as.data.frame(direccion_pca2), "direccion_pca21.csv", row.names = FALSE)
write.csv(as.data.frame(direccion_pca3), "direccion_pca3.csv", row.names = FALSE)


# Calculamos el porcentaje de varianza que explica cada componente
varianza_explicada <- pca_result$sdev^2 / sum(pca_result$sdev^2)

# Dibujamos las primeras 20 barras para no colapsar
barplot(varianza_explicada[1:20] * 100, 
        main = "Varianza Explicada por Componente Principal",
        xlab = "Componentes Principales (PC1 al PC20)",
        ylab = "Varianza (%)",
        col = "steelblue4")

# Comparativa PC1 y PC2
# Dibujamos los 1000 puntos usando el PC1 en el eje X y el PC2 en el eje Y
plot(pca_result$x[,1], pca_result$x[,2], 
     main = "Distribución del Espacio Latente (PC1 vs PC2)",
     xlab = "PC1 (Género / Fondo)",
     ylab = "PC2 (Pelo / Gafas)",
     pch = 16, # Forma del punto (círculo relleno)
     col = rgb(0.2, 0.4, 0.6, alpha = 0.5)) # Color azul semitransparente para ver solapamientos



##### 2. SVM (aprendizaje supervisado) #####

library(e1071)
library(ggplot2)
# 1. Leemos los datos que trajimos de Python
datos <- read.csv("datos_supervisados_tfg.csv")

# 2. Definimos qué columnas son nuestras etiquetas
atributos <- c("smile", "eyeglasses", "gender")

# 3. Bucle para calcular la dirección de cada uno
for (attr in atributos) {
  cat("Calculando la dirección para:", attr, "...\n")
  
  # Creamos la fórmula dinámicamente (ej: smile ~ w_0 + w_1 + ...)
  # Primero limpiamos el dataset para este atributo
  columnas_w <- paste0("w_", 0:511)
  datos_sub <- datos[, c(columnas_w, attr)] # datos de cada variable
  
  # Entrenamos la SVM con Kernel Lineal 
  modelo <- svm(as.formula(paste(attr, "~ .")), #ponemos los atributos en función de todas las demás columnas
                data = datos_sub, 
                kernel = "linear", #debe encontrar una línea recta en el espacio latente
                type = "eps-regression") #regression por ser etiquetas con números continuos

  # Extraemos el vector normal
  # La fórmula matemática es: w = sum(alpha_i * y_i * support_vectors_i)
  direccion <- t(modelo$coefs) %*% modelo$SV  
  # los vectores de soporte (SV) son como las "caras límite", donde ese rasgo aparece exagerado 
  # para más y para menos, como por ejemplo, no sonreír nada y sonreír muchísimo.
  
  # 4. Guardamos el resultado en un CSV individual
  nombre_archivo <- paste0("direccion_svm_", attr, ".csv")
  write.csv(direccion, nombre_archivo, row.names = FALSE)
  
  cat("Guardado como:", nombre_archivo, "\n\n")
}
print("PROCESO FINALIZADO")

# Hagamos un gráfico
# Separamos solo las coordenadas de las 1000 caras
caras_w <- as.matrix(datos[, 1:512])

# Cargamos la "brújula" de la sonrisa que calculaste con la SVM
dir_sonrisa <- read.csv("direccion_svm_smile.csv")

# Proyectamos las caras sobre la flecha (¡as.numeric() evita el error de tamaño!)
proyecciones <- caras_w %*% as.numeric(dir_sonrisa)

# 4. CREAMOS EL DATAFRAME 
df_grafico <- data.frame(
  Proyeccion_SVM = proyecciones,
  Etiqueta = ifelse(datos$smile > 0, "Sonríe (Score > 0)", "No Sonríe (Score < 0)")
)

ggplot(df_grafico, aes(x = Etiqueta, y = Proyeccion_SVM, fill = Etiqueta)) +
  geom_violin(alpha = 0.7, trim = FALSE, color = "darkgray") +
  geom_boxplot(width = 0.15, fill = "white", color = "black", outlier.shape = NA) +
  scale_fill_manual(values = c("Sonríe (Score > 0)" = "#2E8B57", 
                               "No Sonríe (Score < 0)" = "#CD5C5C")) +
  theme_minimal() +
  labs(
    title = "Distribución de la Proyección SVM (Gráfico de Violín)",
    subtitle = "Análisis de la densidad y medianas para el atributo 'Sonrisa'",
    x = "Clasificación Original",
    y = "Puntuación en la Dirección SVM",
    fill = "Categoría:"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none" # Quitamos la leyenda porque el eje X ya lo dice
  )


library(ggplot2)

ggplot(df_grafico, aes(x = Proyeccion_SVM, fill = Etiqueta)) +
  # Usamos barras de histograma en lugar de líneas continuas
  geom_histogram(position = "identity", alpha = 0.6, bins = 40, color = "white") +
  # La línea de separación (el hiperplano SVM)
  geom_vline(xintercept = 0, linetype = "dashed", color = "black", linewidth = 1) +
  scale_fill_manual(values = c("Sonríe (Score > 0)" = "#2E8B57", 
                               "No Sonríe (Score < 0)" = "#CD5C5C")) +
  theme_minimal() +
  labs(
    title = "Separación del Atributo mediante SVM (Histograma)",
    subtitle = "Frecuencia absoluta de imágenes según su distancia al hiperplano",
    x = "Distancia al Hiperplano SVM",
    y = "Número de Imágenes (Frecuencia)",
    fill = "Clasificación:"
  ) +
  theme(plot.title = element_text(face = "bold"))
##### 3. GRÁFICO INTEGRADOR: PCA + Etiquetas Supervisadas #####

# Veamos ahora si las conclusiones que sacamos mirando las imágenes tenían algo de sentido
# Cargamos la librería de gráficos avanzados
library(ggplot2)

cat("Generando gráfico integrador PCA + SVM...\n")

# Juntamos los mundos: Las coordenadas del PCA y las etiquetas de la IA 
# IMPORTANTE: Esto asume que 'datos_w' y 'datos' tienen las mismas 1000 caras en el mismo orden
df_scatter <- data.frame(
  PC1 = pca_result$x[, 1],
  PC2 = pca_result$x[, 2],
  # Creamos la etiqueta de color basándonos en la columna 'smile' de tu segundo CSV
  Etiqueta1 = ifelse(datos$smile > 0, "Sonríe (Score > 0)", "No Sonríe (Score < 0)"),
  Etiqueta2 = ifelse(datos$gender > 0, "Hombre (Score > 0)", "Mujer (Score < 0)"),
  Etiqueta3 = ifelse(datos$eyeglasses > 0, "Gafas (Score > 0)", "No Gafas (Score < 0)")
 
)

# SONRISA
ggplot(df_scatter, aes(x = PC1, y = PC2, color = Etiqueta1)) +
  geom_point(alpha = 0.6, size = 2) + 
  scale_color_manual(values = c("Sonríe (Score > 0)" = "#2E8B57", 
                                "No Sonríe (Score < 0)" = "#CD5C5C")) +
  theme_minimal() +
  labs(
    title = "Distribución de la Sonrisa en el Espacio Principal (PCA)",
    subtitle = "Proyección de las 1000 imágenes generadas",
    x = "PC1",
    y = "PC2",
    color = "Clasificación:"
  ) +
  theme(plot.title = element_text(face = "bold"))

# GÉNERO
ggplot(df_scatter, aes(x = PC1, y = PC2, color = Etiqueta2)) +
  geom_point(alpha = 0.6, size = 2) + 
  scale_color_manual(values = c("Hombre (Score > 0)" = "#2E8B57", 
                                "Mujer (Score < 0)" = "#CD5C5C")) +
  theme_minimal() +
  labs(
    title = "Distribución de el Género en el Espacio Principal (PCA)",
    subtitle = "Proyección de las 1000 imágenes generadas",
    x = "PC1",
    y = "PC2",
    color = "Clasificación:"
  ) +
  theme(plot.title = element_text(face = "bold"))

# GAFAS
ggplot(df_scatter, aes(x = PC1, y = PC2, color = Etiqueta3)) +
  geom_point(alpha = 0.6, size = 2) + 
  scale_color_manual(values = c("Gafas (Score > 0)" = "#2E8B57", 
                                "No Gafas (Score < 0)" = "#CD5C5C")) +
  theme_minimal() +
  labs(
    title = "Distribución de Gafas en el Espacio Principal (PCA)",
    subtitle = "Proyección de las 1000 imágenes generadas",
    x = "PC1",
    y = "PC2",
    color = "Clasificación:"
  ) +
  theme(plot.title = element_text(face = "bold"))
