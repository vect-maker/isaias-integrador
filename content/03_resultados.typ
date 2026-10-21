= Resultados

En esta sección se muestran los resultados obtenidos a lo largo del desarrollo del proyecto, organizados conforme a las fases metodológicas establecidas. En este apartado se puede observar todo el proceso llevado a cabo desde la extracción y adecuación de la base de datos a partir de un repositorio externo, pasando por el análisis exploratorio mediante consultas estructuradas, hasta la aplicación del modelo estadístico bayesiano para facilitar su uso en el campo de la investigación como recurso para el análisis de patrones físicos

Luego de la selección y descarga de la base de datos, se implementaron procesos de carga de datos que permitieron transferir de manera eficiente el volumen de información hacia el sistema gestor de base de datos, garantizando la integridad y consistencia de los registros durante la inserción

==== Importación de datos desde CSV con Python

Este código se utilizó para importar información de un archivo CSV que contiene resultados de laboratorio sanguíneo y almacenarla en una tabla de SQL Server llamada Laboratorio_Sangre. Para ello, establece una conexión con la base de datos, lee los datos del archivo utilizando Pandas, recorre cada registro e inserta la información en la tabla correspondiente. Finalmente, guarda los cambios y cierra la conexión.

=== Importación de librerías

#figure(image("../images/image2.png", width: 88%), caption: [Ingestión de datos: Carga de librerías y conexión a SQL Server])

Este bloque carga las librerías necesarias para el funcionamiento del programa. La librería *pyodbc* se utiliza para establecer la comunicación entre Python y SQL Server mediante un controlador ODBC, permitiendo ejecutar consultas e insertar datos en la base de datos. Por su parte, *pandas*, importada con el alias pd, se emplea para leer y manipular el archivo CSV de forma estructurada, almacenando su contenido en una tabla de datos denominada DataFrame que facilita el acceso a cada registro y columna.

=== Conexión a SQL Server

#figure(image("../images/image2.png", width: 88%), caption: [Ingestión de datos: Carga de librerías y conexión a SQL Server])

Este bloque establece la conexión entre el programa y la base de datos SQL Server. La función pyodbc.connect() crea un canal de comunicación con el servidor utilizando el controlador ODBC Driver 17 for SQL Server, que actúa como intermediario entre Python y SQL Server. El parámetro SERVER=DESKTOP-8BV56AO indica el servidor donde se encuentra la base de datos, mientras que DATABASE=consumo especifica la base de datos con la que se trabajará. La opción Trusted_Connection=yes permite autenticarse utilizando las credenciales del usuario de Windows que ejecuta el programa, evitando el uso de usuario y contraseña explícitos. Una vez establecida la conexión, la instrucción conexion.cursor() crea un cursor, que es el objeto encargado de enviar instrucciones SQL al servidor y gestionar las operaciones de inserción o consulta de datos.

=== Lectura del archivo CSV

#figure(image("../images/image3.png", width: 88%), caption: [Ingestión de datos: Definición de estructura y tipos de datos])

Esta sección se encarga de cargar la información almacenada en el archivo CSV. La función pd.read_csv() lee el archivo ubicado en la ruta especificada y guarda todo su contenido dentro del DataFrame df. El parámetro encoding="utf-8" asegura que los caracteres especiales sean interpretados correctamente, mientras que sep=";" indica que las columnas están separadas por punto y coma. Una vez cargados los datos, len(df) calcula el número total de filas leídas y lo muestra en pantalla para verificar que la carga fue exitosa. Posteriormente, df.head() presenta las primeras cinco filas del archivo, permitiendo validar visualmente que las columnas y los datos se hayan leído correctamente antes de iniciar la importación a la base de datos.

=== Recorrido de los registros e inserción de datos

#figure(image("../images/image4.png", width: 88%), caption: [Ingestión de datos: Inserción por lotes])

Este apartado crea dos variables para llevar el control del proceso de importación, una para almacenar la cantidad de registros que fueron agregados correctamente a la base de datos, mientras que la segunda contabiliza los registros que generan algún problema durante la inserción, luego, La instrucción df.iterrows() recorre cada fila del DataFrame, permitiendo procesar los registros uno por uno. La estructura try se utiliza para intentar realizar la inserción y evitar que el programa se detenga si aparece un error. Dentro de este bloque, cursor.execute() ejecuta una sentencia SQL INSERT INTO, cuyo propósito es agregar un nuevo registro a la tabla Laboratorio_Sangre. Los símbolos ? funcionan como parámetros de seguridad que serán reemplazados por los valores extraídos de cada columna del DataFrame, tales como el identificador del laboratorio, el identificador del paciente, la glucosa en sangre, colesterol total, colesterol HDL, colesterol LDL, triglicéridos y hemoglobina. Si la inserción se realiza correctamente, la variable filas_insertadas aumenta en una unidad para registrar el éxito de la operación.

=== Manejo de errores

#figure(image("../images/image5.png", width: 88%), caption: [Ingestión de datos: Manejo de transacciones y errores])

Este bloque se ejecuta únicamente cuando ocurre un error durante la inserción de un registro. Exception as e captura la descripción del error generado por Python o SQL Server. La instrucción print() muestra en pantalla el número de fila que produjo el problema junto con el mensaje de error correspondiente, facilitando la identificación y corrección de datos incorrectos. Además, filas_error += 1 incrementa el contador de errores para reflejar cuántos registros no pudieron ser importados.

=== Confirmación de los cambios y cierre de cursos

#figure(image("../images/image6.png", width: 88%), caption: [Ingestión de datos: Confirmación de commit y cierre])

Una vez finalizado l recorrido de todos los registros, conexion.commit() confirma y guarda permanentemente todas las inserciones realizadas en SQL Server. Esta instrucción es fundamental, ya que sin ella los cambios quedarían pendientes y no se almacenarían en la base de datos. Posteriormente, se muestra un mensaje resumen indicando cuántos registros fueron insertados exitosamente y cuántos presentaron errores durante el proceso.

La instrucción cursor.close() libera el cursor utilizado para ejecutar sentencias SQL, mientras que conexion.close() cierra la conexión con SQL Server. Esto ayuda a liberar memoria y recursos del sistema, además de evitar conexiones abiertas innecesariamente en el servidor de base de datos.

== Exportación de datos de SQL Server a CSV con Python

Este programa automatiza la exportación de información desde SQL Server hacia un archivo CSV. Primero establece una conexión con la base de datos, luego ejecuta una consulta para obtener todos los registros de la tabla Laboratorio_Sangre, almacena los resultados en un DataFrame de Pandas y finalmente los exporta a un archivo CSV listo para ser utilizado en análisis, reportes o herramientas como Excel. Al finalizar, cierra la conexión para liberar los recursos empleados durante el proceso.

=== Importación de librerías

#figure(image("../images/image7.png", width: 88%), caption: [Exportación de datos: Importación de librerías])

Esta sección carga las librerías necesarias para la ejecución del programa. La librería *pyodbc* permite establecer la conexión entre Python y SQL Server para acceder a la información almacenada en la base de datos. La librería *panda*, importada con el alias pd, se utiliza para manipular datos en formato tabular y facilitar la exportación de los resultados a un archivo CSV. También se importa la librería *os*, que proporciona herramientas para trabajar con rutas y archivos del sistema operativo, aunque en este programa no se utiliza directamente.

=== Conexión a SQL Server

#figure(image("../images/image8.png", width: 88%), caption: [Exportación de datos: Conexión y ejecución de consulta])

Esta sección establece la conexión con la base de datos SQL Server. La función pyodbc.connect() crea un enlace entre Python y el servidor de base de datos utilizando el controlador *ODBC Driver 17 for SQL Server*. El parámetro SERVER=DESKTOP-8BV56AO indica el servidor donde se encuentra alojada la base de datos, mientras que DATABASE=consumo especifica la base de datos que se utilizará. La opción Trusted_Connection=yes permite que la autenticación se realice mediante las credenciales del usuario de Windows, evitando la necesidad de proporcionar un usuario y contraseña dentro del código.

=== Ejecución de la consulta y obtención de datos

#figure(image("../images/image8.png", width: 88%), caption: [Exportación de datos: Conexión y ejecución de consulta])

Esta sección se encarga de recuperar la información almacenada en la base de datos. Primero, la variable consulta almacena una sentencia SQL que selecciona todos los registros de la tabla Laboratorio_Sangre mediante la instrucción SELECT \*. Posteriormente, la función pd.read_sql() ejecuta la consulta utilizando la conexión previamente creada y almacena el resultado en un DataFrame llamado df. De esta forma, toda la información obtenida queda disponible para ser procesada con Pandas. Finalmente, len(df) muestra la cantidad total de registros recuperados y df.head() presenta las primeras cinco filas para verificar que la extracción de datos se haya realizado correctamente

=== Exportación de datos a un archivo CSV

#figure(image("../images/image9.png", width: 88%), caption: [Exportación de datos: Exportación a archivo CSV])

Esta sección guarda los datos obtenidos de la base de datos en un archivo CSV. La variable ruta_salida define la ubicación y el nombre del archivo que se generará. A continuación, la función df.to_csv() exporta el contenido completo del DataFrame hacia dicha ruta. El parámetro index=False evita que se incluya la numeración automática de Pandas como una columna adicional en el archivo. La opción encoding="utf-8-sig" utiliza una codificación compatible con Excel, permitiendo visualizar correctamente caracteres especiales y acentos. Por último, sep="," establece que las columnas estarán separadas por comas. Una vez completada la exportación, se muestra un mensaje indicando la ubicación donde se guardó el archivo.

=== Cierre de coneccion

#figure(image("../images/image9.png", width: 88%), caption: [Exportación de datos: Exportación a archivo CSV])

Esta sección finaliza la comunicación con SQL Server. La instrucción conexion.close() cierra la conexión abierta al inicio del programa, liberando los recursos utilizados tanto en Python como en el servidor de base de datos. Esto garantiza una finalización adecuada del proceso y evita mantener conexiones abiertas innecesariamente.

== Consultas Analíticas en SQL Server

=== Promedio de colesterol LDL y triglicéridos según el sexo

*Funciones utilizadas:*  AVG, CASE, JOIN, GROUP BY \
*Descripción:*  Calcula el promedio de colesterol LDL y triglicéridos en hombres y mujeres para comparar los niveles de estas grasas en la sangre entre ambos grupos.

#figure(image("../images/image10.png", width: 88%), caption: [Consulta SQL: Promedio de colesterol LDL y triglicéridos según el sexo])

=== Presión sistólica máxima y mínima por edad

*Funciones utilizadas:*  MAX, MIN, JOIN, GROUP BY \
*Descripción:*  Muestra la presión sistólica más alta y más baja registrada para cada edad, permitiendo observar cómo varían los niveles de presión arterial entre diferentes grupos etarios.

#figure(image("../images/image11.png", width: 88%), caption: [Consulta SQL: Presión sistólica máxima y mínima por edad])

=== Cantidad de pacientes diabéticos según hábito de fumar

*Funciones utilizadas:*  COUNT, JOIN, WHERE, GROUP BY \
*Descripción:*  Cuenta cuántos pacientes con niveles de glucosa compatibles con diabetes existen en cada categoría de hábito de fumar, permitiendo analizar la distribución de la diabetes según el consumo de tabaco.

#figure(image("../images/image12.png", width: 88%), caption: [Consulta SQL: Cantidad de pacientes diabéticos según hábito de fumar])

=== Edad promedio de personas con problemas auditivos

*Funciones utilizadas:*  AVG, JOIN, WHERE, UNION ALL \
*Descripción:*  Calcula la edad promedio de las personas que presentan problemas de audición en el oído izquierdo y en el oído derecho, facilitando la identificación de los grupos de edad más afectados.

#figure(image("../images/image13.png", width: 88%), caption: [Consulta SQL: Edad promedio de personas con problemas auditivos])

=== Cantidad y edad promedio de fumadores

*Funciones utilizadas:*  COUNT, AVG, ROUND, CASE, JOIN, GROUP BY, UNION ALL \
*Descripción:*  Muestra cuántos fumadores hay y cuál es su edad promedio, diferenciando los resultados por sexo y presentando además un total general de fumadores.

#figure(image("../images/image14.png", width: 88%), caption: [Consulta SQL: Cantidad y edad promedio de fumadores])

=== Bebedores con posible daño renal

*Funciones utilizadas:*  CASE, JOIN, WHERE \
*Descripción:*  Identifica a los pacientes que consumen alcohol y presentan niveles elevados de proteínas en la orina, una condición que puede estar relacionada con posibles problemas renales.

#figure(image("../images/image15.png", width: 88%), caption: [Consulta SQL: Bebedores con posible daño renal])

=== Bebedores y fumadores por sexo

*Funciones utilizadas:*  SUM, CASE, COUNT, JOIN, GROUP BY \
*Descripción:*  Muestra la cantidad de bebedores y fumadores en hombres y mujeres, permitiendo comparar estos hábitos entre ambos sexos y conocer el total de pacientes evaluados.

#figure(image("../images/image16.png", width: 88%), caption: [Consulta SQL: Bebedores y fumadores por sexo])

=== Hallazgos médicos en no fumadores y no bebedores

*Funciones utilizadas:*  CASE, COUNT, AVG, ROUND, JOIN, WHERE, GROUP BY \
*Descripción:*  Identifica cuántos pacientes que no fuman ni consumen alcohol presentan colesterol alto o posibles problemas renales, mostrando además la edad promedio de cada grupo.

#figure(image("../images/image17.png", width: 88%), caption: [Consulta SQL: Hallazgos médicos en no fumadores y no bebedores])

=== Comparación del LDL individual contra el promedio de su grupo de fumadores

*Funciones utilizadas:*  CASE, AVG OVER(PARTITION BY), JOIN, WHERE \
*Descripción:*  Compara el nivel de colesterol LDL de cada paciente con el promedio de LDL de las personas que pertenecen a su misma categoría de tabaquismo (no fumador, exfumador o fumador actual).

#figure(image("../images/image18.png", width: 88%), caption: [Consulta SQL: Comparación del LDL individual contra el promedio del grupo])

=== Medidas de cintura según consumo de alcohol

*Funciones utilizadas:*  AVG, MIN, MAX, COUNT, CASE, JOIN, WHERE, GROUP BY, ROUND \
*Descripción:*  Analiza las medidas de cintura de bebedores y no bebedores, mostrando el promedio, el valor mínimo, el máximo y la cantidad de pacientes en cada grupo.

#figure(image("../images/image19.png", width: 88%), caption: [Consulta SQL: Medidas de cintura según consumo de alcohol])

=== Niveles de proteína en orina por sexo

*Funciones utilizadas:*  COUNT, CASE, JOIN, GROUP BY, ORDER BY \
*Descripción:*  Muestra cuántos hombres y mujeres presentan cada nivel de proteína en la orina, permitiendo comparar la distribución de posibles alteraciones renales entre ambos sexos.

#figure(image("../images/image20.png", width: 88%), caption: [Consulta SQL: Niveles de proteína en orina por sexo])

=== Casos críticos renales por edad

*Funciones utilizadas:*  COUNT, JOIN, WHERE, GROUP BY, HAVING \
*Descripción:*  Identifica las edades que presentan una cantidad significativa de pacientes con niveles críticos de proteína en la orina, considerando únicamente los grupos con más de 50 casos registrados.

#figure(image("../images/image21.png", width: 88%), caption: [Consulta SQL: Casos críticos renales por edad])

=== Comparación del estado renal dentro del mismo grupo de edad

*Funciones utilizadas:*  MAX OVER(PARTITION BY), JOIN \
*Descripción:*  Muestra el nivel de proteína en orina de cada paciente y lo compara con el caso renal más grave registrado entre las personas de su misma edad.

#figure(image("../images/image22.png", width: 88%), caption: [Consulta SQL: Comparación del estado renal en el mismo grupo etario])

=== Pacientes con diabetes y alteraciones renales

*Funciones utilizadas:*  CASE, JOIN, WHERE \
*Descripción:*  Identifica pacientes con niveles de glucosa compatibles con diabetes que además presentan proteínas en la orina por encima de lo normal, ayudando a detectar posibles complicaciones renales asociadas.

#figure(image("../images/image23.png", width: 88%), caption: [Consulta SQL: Pacientes con diabetes y alteraciones renales])

=== Niveles de proteína en orina en fumadores

*Funciones utilizadas:*  COUNT, JOIN, WHERE, GROUP BY, ORDER BY \
*Descripción:*  Muestra cuántos fumadores presentan cada nivel de proteína en la orina, permitiendo observar la frecuencia de posibles alteraciones renales dentro de este grupo.

#figure(image("../images/image24.png", width: 88%), caption: [Consulta SQL: Niveles de proteína en orina en fumadores])

=== Niveles de proteína en orina en bebedores

*Funciones utilizadas:*  COUNT, JOIN, WHERE, GROUP BY, ORDER BY \
*Descripción:*  Muestra cuántos consumidores de alcohol presentan cada nivel de proteína en la orina, facilitando el análisis de posibles problemas renales asociados al consumo de alcohol

#figure(image("../images/image25.png", width: 88%), caption: [Consulta SQL: Niveles de proteína en orina en bebedores])

=== Bebedores y fumadores con indicadores de salud dentro de rangos normales

*Funciones utilizadas:*  CASE, JOIN, WHERE \
*Descripción:*  Identifica pacientes que consumen alcohol y fuman, pero que mantienen niveles normales de glucosa, colesterol, función renal y presión arterial, permitiendo encontrar casos que, a pesar de estos hábitos, no muestran alteraciones importantes en los indicadores evaluados.

#figure(image("../images/image26.png", width: 88%), caption: [Consulta SQL: Indicadores de salud en rangos normales])

=== Perfil de fumadores y bebedores según edad

*Funciones utilizadas:*  MIN, MAX, COUNT, JOIN, WHERE, UNION ALL \
*Descripción:*  Muestra el rango de edades y la cantidad total de pacientes que son fumadores activos y consumidores de alcohol, permitiendo conocer el tamaño y la distribución de edad de ambos grupos.

#figure(image("../images/image27.png", width: 88%), caption: [Consulta SQL: Perfil de fumadores y bebedores según edad])

=== Casos de anemia por edad

*Funciones utilizadas:*  COUNT, AVG, MIN, ROUND, JOIN, WHERE, GROUP BY, HAVING, ORDER BY \
*Descripción:*  Identifica los grupos de edad con una alta cantidad de pacientes que presentan niveles bajos de hemoglobina (anemia), mostrando además el promedio y el valor mínimo de hemoglobina detectado en cada grupo.

#figure(image("../images/image28.png", width: 88%), caption: [Consulta SQL: Casos de anemia por edad])

=== Peso promedio de consumidores de alcohol por sexo

*Funciones utilizadas:*  AVG, COUNT, ROUND, CASE, JOIN, WHERE, GROUP BY \
*Descripción:*  Calcula el peso promedio de los pacientes que consumen alcohol, diferenciando los resultados entre hombres y mujeres para comparar las características físicas de ambos grupos.

#figure(image("../images/image29.png", width: 88%), caption: [Consulta SQL: Peso promedio de consumidores de alcohol por sexo])

== Interpretación y Clasificación de las Variables

==== Variable respuesta

Se analizaron dos variables respuesta relacionadas con hábitos de consumo:

*DRK_YN:*  variable binaria donde 1 representa individuos consumidores de alcohol y 0 individuos no consumidores. Esta variable fue modelada mediante una distribución Bernoulli utilizando regresión logística bayesiana.

*SMK_stat_type_cd:*  variable categórica correspondiente al estado de fumador, clasificada en diferentes categorías de consumo de tabaco. Esta variable fue analizada mediante modelos bayesianos multinomiales.

==== Variables predictoras

Las variables seleccionadas se eligieron por su relevancia fisiológica y epidemiológica en estudios asociados al consumo de alcohol y tabaquismo.

==== Variables antropométricas

- age (edad)
- weight (peso corporal)
- waistline (perímetro de cintura)
==== Variables cardiovasculares

- SBP (presión arterial sistólica)
- DBP (presión arterial diastólica)
==== Variables metabólicas y bioquímicas

- triglyceride (triglicéridos)
- hemoglobin (hemoglobina)
==== Variables hepáticas

- SGOT_AST
- SGOT_ALT
- gamma_GTP
Estas variables fueron utilizadas como predictores de la probabilidad de pertenecer a los grupos de consumidores de alcohol y fumadores.

==== Relación propuesta

Se asumió que el logaritmo de las odds de consumo de alcohol puede expresarse como una combinación lineal de las variables explicativas:

logit(pᵢ) = β₀ + β₁(ageᵢ) + β₂(weightᵢ) + β₃(waistlineᵢ) + β₄(SBPᵢ) + β₅(DBPᵢ) + β₆(triglycerideᵢ) + β₇(hemoglobinᵢ) + β₈(SGOT_ASTᵢ) + β₉(SGOT_ALTᵢ) + β₁₀(gamma_GTPᵢ)

donde pᵢ representa la probabilidad de que el individuo pertenezca a la categoría de consumidor de alcohol.

La función logit garantiza que las probabilidades estimadas permanezcan dentro del intervalo (0,1) y permite interpretar los coeficientes mediante odds ratios.

==== Estandarización de variables

Debido a que las variables poseen escalas muy diferentes, las variables continuas fueron estandarizadas mediante puntajes Z antes del ajuste del modelo.

La estandarización permitió:

- Mejorar la estabilidad numérica del algoritmo.
- Facilitar la convergencia de las cadenas MCMC.
- Comparar directamente la magnitud de los coeficientes.
== Aplicación del Modelo Bayesiano

La probabilidad de consumo de alcohol fue modelada mediante una distribución Bernoulli:

yᵢ ~ Bernoulli(pᵢ)

donde:

pᵢ = 1 / (1 + exp(-(Xᵢβ)))

Los parámetros del modelo correspondieron al intercepto y a los coeficientes asociados a cada una de las diez variables predictoras.

==== Distribuciones a priori

Se utilizaron distribuciones normales débilmente informativas para todos los coeficientes:

βⱼ ~ N(0,1000)

Esta especificación permitió que la evidencia observada en los datos dominara el proceso de inferencia, sin imponer supuestos fuertes previos sobre la dirección o magnitud de los efectos.

==== Distribución posterior

La distribución posterior fue obtenida mediante el Teorema de Bayes:

Posterior ∝ Verosimilitud × Prior

Debido a que la distribución posterior no posee una forma analítica cerrada en la regresión logística, fue necesario utilizar métodos de simulación para aproximarla.

==== Aplicación de MCMC

La estimación de los parámetros se realizó mediante el algoritmo Markov Chain Monte Carlo (MCMC), implementado mediante la función MCMClogit() de la librería MCMCpack.

El procedimiento consistió en:

- Definir la matriz de variables predictoras.
- Especificar la distribución Bernoulli de la variable respuesta.
- Inicializar los coeficientes.
- Ejecutar múltiples iteraciones MCMC.
- Descartar las iteraciones iniciales (burn-in).
- Obtener muestras de la distribución posterior.
- Calcular estadísticas resumen para cada parámetro.
Las cadenas generadas fueron evaluadas mediante gráficos de trayectoria (trace plots) y distribuciones posteriores (density plots), verificando la convergencia y estabilidad del proceso de simulación.

== Resultados de los Modelos Bayesianos

Para cada coeficiente se estimaron:

- Media posterior.
- Mediana posterior.
- Desviación estándar posterior.
- Intervalos HPD al 95%.
- Odds Ratio (OR = exp(β)).
La media posterior representó la estimación promedio del efecto de cada variable sobre la probabilidad de consumo de alcohol.

La desviación estándar posterior cuantificó la incertidumbre asociada a cada coeficiente.

Los intervalos HPD al 95% permitieron identificar las variables con evidencia de efecto estadísticamente relevante. Aquellas cuyo intervalo no incluyó el valor cero fueron consideradas variables asociadas al consumo de alcohol.

Los coeficientes fueron transformados a odds ratios para facilitar la interpretación práctica de los resultados. Valores de OR superiores a 1 indicaron aumento en la probabilidad de pertenecer al grupo consumidor, mientras que valores inferiores a 1 indicaron disminución de dicha probabilidad.

#figure(image("../images/image30.png", width: 88%), caption: [Comparación de Odds Ratios (OR) e intervalos de credibilidad HPD 95%])

La matriz de correlación de Spearman permitió identificar relaciones relevantes entre las variables seleccionadas para el estudio. Las asociaciones más fuertes se observaron entre weight y waistline (ρ = 0.78), SBP y DBP (ρ = 0.73), y entre las enzimas hepáticas SGOT_AST y SGOT_ALT (ρ = 0.73). Asimismo, gamma_GTP presentó correlaciones moderadas con SGOT_ALT (ρ = 0.62), weight (ρ = 0.46) y waistline (ρ = 0.47), sugiriendo una relación entre los marcadores hepáticos y variables antropométricas. En general, los resultados evidencian que las variables cardiovasculares, metabólicas y hepáticas presentan asociaciones consistentes, lo que respalda su utilización en los modelos de clasificación de consumidores de alcohol y fumadores.

#figure(image("../images/image31.png", width: 88%), caption: [Matriz de correlación de Spearman entre variables clínicas y biométricas])

La simulación Monte Carlo aplicada a la variable gamma_GTP permitió analizar su comportamiento probabilístico mediante la generación de 10,000 observaciones simuladas. El histograma obtenido muestra una distribución asimétrica positiva, donde la mayoría de los valores se concentran en niveles bajos y existe una cola larga hacia valores elevados. Este comportamiento indica que, aunque la mayor parte de la población presenta niveles normales o moderados de gamma_GTP, existe un grupo reducido con concentraciones considerablemente más altas, posiblemente asociadas a alteraciones hepáticas o hábitos de consumo de alcohol. La simulación permitió representar adecuadamente la incertidumbre y variabilidad de esta variable, justificando su inclusión dentro de los análisis probabilísticos y modelos bayesianos desarrollados en el estudio.

=== Resultados del Modelo Bayesiano para Consumo de Alcohol

#align(center)[#table(
  columns: (2.2fr, 1.2fr, 1fr, 1fr, 1fr, 1.1fr),
  align: (col, row) => if row == 0 { center + horizon } else if col == 0 { left + horizon } else { right + horizon },
  stroke: 0.5pt + luma(180),
  fill: (col, row) => if row == 0 { rgb("eef2f7") } else if calc.even(row) { rgb("fafbfc") } else { none },
  [*_Variable_*], [*_Media Posterior (β)_*], [*_Desv. Estándar_*], [*_HPD 2.5%_*], [*_HPD 97.5%_*], [*_Odds Ratio (OR)_*],
  [Intercepto], [-2.7827], [0.3068], [-3.3948], [-2.2193], [0.0619],
  [Edad], [-0.0384], [0.0020], [-0.0417], [-0.0343], [0.9623],
  [Peso], [0.0352], [0.0037], [0.0271], [0.0422], [1.0358],
  [Circunferencia cintura], [-0.0161], [0.0045], [-0.0253], [-0.0078], [0.9840],
  [Presión sistólica (SBP)], [-0.0022], [0.0025], [-0.0067], [0.0024], [0.9978],
  [Presión diastólica (DBP)], [0.0107], [0.0036], [0.0038], [0.0176], [1.0107],
  [Triglicéridos], [-0.0004], [0.0002], [-0.0009], [0.0001], [0.9996],
  [Hemoglobina], [0.2055], [0.0174], [0.1746], [0.2424], [1.2281],
  [SGOT_AST], [0.0109], [0.0030], [0.0049], [0.0167], [1.0110],
  [SGOT_ALT], [-0.0230], [0.0020], [-0.0271], [-0.0192], [0.9772],
  [Gamma_GTP], [0.0180], [0.0011], [0.0158], [0.0200], [1.0181],
)]

Los resultados muestran que las variables edad, peso, circunferencia de cintura, presión arterial diastólica, hemoglobina, SGOT_AST, SGOT_ALT y gamma_GTP presentan intervalos HPD al 95% que no incluyen el valor cero, indicando evidencia de asociación con la clasificación de consumidores de alcohol.

La variable hemoglobina presentó el mayor efecto positivo (β = 0.2055), con un odds ratio de 1.2281, indicando que por cada unidad de incremento en hemoglobina las probabilidades relativas de pertenecer al grupo consumidor de alcohol aumentan aproximadamente un 22.8%.

Por otro lado, gamma_GTP mostró un coeficiente positivo (β = 0.0180) y un intervalo HPD completamente positivo, lo que confirma una asociación consistente entre el aumento de esta enzima hepática y el consumo de alcohol.

Las variables SBP y triglicéridos no mostraron evidencia suficiente de efecto debido a que sus intervalos HPD incluyen el valor cero.

=== Resultados del Modelo Bayesiano para Tabaquismo

#align(center)[#table(
  columns: (2.2fr, 1.2fr, 1fr, 1fr, 1fr, 1.1fr),
  align: (col, row) => if row == 0 { center + horizon } else if col == 0 { left + horizon } else { right + horizon },
  stroke: 0.5pt + luma(180),
  fill: (col, row) => if row == 0 { rgb("eef2f7") } else if calc.even(row) { rgb("fafbfc") } else { none },
  [*_Variable_*], [*_Media Posterior (β)_*], [*_Desv. Estándar_*], [*_HPD 2.5%_*], [*_HPD 97.5%_*], [*_Odds Ratio (OR)_*],
  [Intercepto], [-11.4561], [0.4789], [-12.3247], [-10.5183], [0.00001],
  [Edad], [-0.0093], [0.0026], [-0.0145], [-0.0043], [0.9908],
  [Peso], [0.0416], [0.0046], [0.0332], [0.0508], [1.0425],
  [Circunferencia cintura], [-0.0180], [0.0059], [-0.0301], [-0.0073], [0.9822],
  [Presión sistólica (SBP)], [-0.0107], [0.0034], [-0.0165], [-0.0037], [0.9894],
  [Presión diastólica (DBP)], [0.0053], [0.0048], [-0.0042], [0.0142], [1.0053],
  [Triglicéridos], [0.0019], [0.0003], [0.0012], [0.0025], [1.0019],
  [Hemoglobina], [0.7052], [0.0272], [0.6549], [0.7592], [2.0243],
  [SGOT_AST], [0.0027], [0.0034], [-0.0041], [0.0091], [1.0027],
  [SGOT_ALT], [-0.0165], [0.0025], [-0.0211], [-0.0114], [0.9836],
  [Gamma_GTP], [0.0107], [0.0010], [0.0089], [0.0126], [1.0108],
)]

Los resultados muestran que *edad, peso, circunferencia de cintura, presión arterial sistólica, triglicéridos, hemoglobina, SGOT_ALT y gamma_GTP* presentan intervalos HPD que no incluyen el valor cero, indicando evidencia de asociación con la clasificación de fumadores.

La variable más influyente fue *hemoglobina* (β = 0.7052), con un odds ratio de 2.0243. Esto significa que un incremento unitario en esta variable duplica aproximadamente las probabilidades relativas de pertenecer al grupo de fumadores.

Los *triglicéridos* también mostraron un efecto positivo consistente, mientras que *SGOT_ALT* presentó una asociación negativa. Asimismo, *gamma_GTP* mantuvo una relación positiva con la probabilidad de tabaquismo.

Las variables *DBP* y *SGOT_AST* no mostraron evidencia suficiente de efecto debido a que sus intervalos HPD incluyen el valor cero.

#figure(image("../images/image32.png", width: 88%), caption: [Diagrama de transición y probabilidades de Cadenas de Márkov])

Con el objetivo de comparar el comportamiento de las variables seleccionadas en ambos modelos, se construyó una representación gráfica basada en los intervalos de densidad posterior más alta (HPD) al 95%, obtenidos a partir de los modelos de regresión logística bayesiana ajustados mediante MCMC. Los puntos en la figura representan la media posterior de cada coeficiente y las barras horizontales su intervalo HPD, utilizando como referencia la línea β = 0 para determinar si existe evidencia de asociación.

Los resultados muestran que la hemoglobina fue el predictor más relevante en ambos modelos. En el modelo de alcohol se obtuvo un coeficiente de 0.2055 con intervalo HPD [0.1746, 0.2424], mientras que en el de tabaquismo fue de 0.7052 con intervalo [0.6549, 0.7592]; al situarse ambos intervalos completamente por encima de cero, la evidencia de asociación positiva es sólida, siendo el efecto notablemente más pronunciado en el modelo de tabaquismo. El peso corporal y la gamma_GTP también mostraron asociaciones positivas consistentes en ambos modelos, coherentes con la literatura médica sobre marcadores bioquímicos vinculados al consumo de alcohol y tabaco.

Por el contrario, la edad, la circunferencia de cintura y SGOT_ALT presentaron coeficientes negativos con intervalos HPD que no incluyen el cero, lo que indica una relación inversa con la probabilidad de pertenecer a los grupos analizados. Variables como SBP, DBP, SGOT_AST y triglicéridos mostraron efectos de menor magnitud o evidencia insuficiente para afirmar una asociación significativa.

En conjunto, los resultados evidencian que variables hematológicas, antropométricas y bioquímicas contienen información relevante para la clasificación probabilística de individuos según sus hábitos de consumo, y demuestran la capacidad de los modelos bayesianos basados en MCMC para producir estimaciones robustas que incorporan explícitamente la incertidumbre en los datos.

=== Interpretación de las variables más relevantes

Las variables hepáticas SGOT_AST, SGOT_ALT y gamma_GTP mostraron especial interés debido a su estrecha relación con el metabolismo y daño hepático asociado al consumo frecuente de alcohol.

Asimismo, variables como triglyceride, waistline y weight permitieron evaluar posibles alteraciones metabólicas relacionadas con hábitos de consumo.

En el análisis de tabaquismo, variables como hemoglobin, SBP y DBP aportaron información relevante para la clasificación de los distintos estados de fumador.

=== Aportación a la toma de decisiones

Los resultados obtenidos mediante el análisis de correlación, las simulaciones Monte Carlo, las cadenas de Márkov y los modelos de regresión logística bayesiana permiten generar evidencia estadística sólida para comprender los factores asociados al consumo de alcohol y al tabaquismo. A diferencia de los enfoques tradicionales que únicamente identifican relaciones descriptivas entre variables, el enfoque bayesiano utilizado en este estudio permite cuantificar explícitamente la incertidumbre y estimar probabilidades posteriores de pertenencia a cada categoría de consumo.

Desde una perspectiva de salud pública, los hallazgos permiten identificar variables fisiológicas y bioquímicas que presentan una asociación significativa con los hábitos de consumo. Variables como la hemoglobina, el peso corporal, la gamma glutamil transferasa (gamma_GTP) y determinados indicadores hepáticos mostraron una influencia importante sobre la probabilidad de que un individuo sea consumidor de alcohol o fumador. Esta información puede ser utilizada para establecer perfiles de riesgo y apoyar programas de prevención temprana.

El modelo bayesiano desarrollado constituye una herramienta de apoyo para la toma de decisiones clínicas y epidemiológicas, ya que permite estimar la probabilidad de que una persona pertenezca a un grupo de riesgo considerando simultáneamente múltiples variables. Esto facilita la identificación de individuos con mayor probabilidad de presentar conductas asociadas al consumo de alcohol o tabaquismo, incluso cuando dichas conductas no han sido reportadas directamente.

Asimismo, las simulaciones Monte Carlo permitieron evaluar la variabilidad e incertidumbre de variables críticas relacionadas con el consumo de alcohol, generando escenarios probabilísticos que permiten comprender mejor el comportamiento esperado de la población estudiada. Este tipo de análisis resulta especialmente útil para instituciones de salud y organismos gubernamentales interesados en diseñar estrategias preventivas basadas en evidencia cuantitativa.

Por otra parte, las cadenas de Márkov permitieron modelar las probabilidades de transición entre distintos estados de riesgo asociados a los niveles de gamma_GTP. Los resultados indicaron que existe una alta probabilidad de permanencia o transición hacia estados considerados normales, aunque también se observaron probabilidades no despreciables de transición hacia estados elevados y muy elevados. Esta información puede utilizarse para monitorear la evolución de indicadores relacionados con el consumo de alcohol y para diseñar programas de seguimiento de pacientes.

La comparación entre los modelos de alcohol y tabaquismo reveló diferencias importantes en la magnitud del efecto de ciertas variables. En particular, la hemoglobina mostró una asociación considerablemente más fuerte con el tabaquismo que con el consumo de alcohol, lo que sugiere que este biomarcador podría utilizarse como un indicador relevante dentro de sistemas de clasificación automática de fumadores. De igual manera, la presencia de efectos consistentes en variables como gamma_GTP y peso corporal demuestra que estos factores pueden contribuir significativamente al desarrollo de modelos predictivos de salud.

Los resultados obtenidos también tienen aplicaciones dentro del ámbito de la Ciencia de Datos. Los coeficientes posteriores estimados pueden ser incorporados en sistemas de clasificación probabilística, algoritmos de predicción de riesgo o sistemas de apoyo a la decisión médica. Debido a que el modelo proporciona probabilidades en lugar de clasificaciones rígidas, las decisiones pueden adaptarse según diferentes niveles de riesgo o criterios establecidos por especialistas.

Finalmente, el presente estudio demuestra que la integración de técnicas estadísticas bayesianas, simulaciones Monte Carlo y cadenas de Márkov constituye una metodología robusta para el análisis de comportamientos relacionados con la salud. La capacidad de cuantificar incertidumbre, identificar variables influyentes y generar predicciones probabilísticas convierte a esta propuesta en una herramienta valiosa para investigadores, profesionales de la salud y responsables de políticas públicas orientadas a la prevención del consumo de alcohol y tabaquismo.

