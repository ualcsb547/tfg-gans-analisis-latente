# Análisis y Manipulación del Espacio Latente en Redes GAN

Este repositorio contiene el código desarrollado para el Trabajo de Fin de Grado (TFG) en Matemáticas. El proyecto se centra en la edición semántica controlada de imágenes generadas artificialmente mediante la arquitectura StyleGAN, explorando su espacio latente a través de técnicas de reducción de dimensionalidad y clasificación.

## Herramientas y Tecnologías
El flujo de trabajo implementa un procedimiento híbrido que aprovecha las fortalezas de distintos entornos:
* **Python (PyTorch / Google Colab):** Utilizado para el manejo de la arquitectura generativa, la síntesis de imágenes y la extracción inicial de las representaciones del espacio latente.
* **R:** Empleado para el análisis estadístico profundo, incluyendo el cálculo del Análisis de Componentes Principales (PCA) y el entrenamiento de Máquinas de Vectores de Soporte (SVM) para la extracción de direcciones geométricas.

## Estructura del Repositorio
* `python_colab/`: Notebooks y scripts para la instanciación del modelo y extracción de datos.
* `r_scripts/`: Código fuente para la aplicación de PCA, entrenamiento de las SVM y visualización de las fronteras de decisión.
* `data/`: Archivos tabulares con las coordenadas del espacio latente y las etiquetas de los atributos. *(Nota: Por restricciones de tamaño, los pesos del modelo original no se incluyen aquí).*
* `docs/`: Gráficos, diagramas de dispersión y figuras generadas resultantes del análisis.

## Guía de Ejecución
1. **Fase Generativa:** Ejecutar los notebooks de la carpeta `python_colab/` para generar las muestras y exportar las coordenadas latentes en formato `.csv`.
2. **Fase Analítica:** Importar los datos resultantes en el script principal de R (`r_scripts/main_analysis.R`) para calcular los hiperplanos separadores y aislar las direcciones semánticas (ej. añadir sonrisa, cambiar género).

## Metodología
Se implementa un enfoque que combina álgebra lineal y aprendizaje automático:
1. Muestreo de vectores aleatorios y propagación a través de la red de mapeo.
2. Aplicación de PCA para reducir la dimensionalidad y estudiar la varianza del espacio.
3. Entrenamiento de modelos SVM lineales para clasificar atributos binarios, utilizando el vector normal al hiperplano como la dirección de manipulación semántica.

## Autor
* **[Cristina Sánchez Beltrán]** - Estudiante de Matemáticas
