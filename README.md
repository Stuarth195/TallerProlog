# Orientador CE
Sistema Experto de Orientación Vocacional en Prolog

Curso: Paradigmas de Programación (CE1106) — Instituto Tecnológico de Costa Rica (TEC)

Integrantes y Carnés:
- Raul Ramirez Villegas (Carné: 2024157970)
- David Solís Méndez (Carné: 2019052194)
- Claudio Arce Cascante (Carné: 201058559)

## 1. Instrucciones para Ejecutar y Utilizar el Programa

El sistema está desarrollado íntegramente en Prolog. Para su ejecución se requiere tener instalado un intérprete compatible, como SWI-Prolog.

1. Colocar los archivos fuente del proyecto en una misma carpeta: `BD.pl`, `BNF.pl` y `Logic.pl`.
2. Abrir la terminal o el entorno de SWI-Prolog y ubicarse en el directorio de los archivos.
3. Cargar el módulo principal de control e integración ejecutando la siguiente consulta en la consola:

```prolog
?- [logic].
```

4. Iniciar la interacción interactiva por consola ejecutando el predicado de inicio:

```prolog
?- iniciar_orientador.
```

5. Responder a cada una de las preguntas del sistema utilizando frases completas en lenguaje natural (español). El programa interpretará de manera automática si expresa una preferencia afirmativa o negativa.

## 2. Descripción Breve de los Hechos, las Reglas y las Listas Utilizadas

### Hechos (Módulo BD.pl)
Almacenan la base de conocimientos estática del sistema. Se definen al menos 10 profesiones profesionales asociadas a sus características particulares mediante predicados relacionales.

### Listas (Módulo BD.pl)
Se utilizan estructuras de listas de Prolog para agrupar de forma ordenada los conjuntos de afinidades/fortalezas requeridas y los aspectos incompatibles de cada carrera (por ejemplo, `profesion(ingenieria_en_computadores, [matematicas, tecnologia, resolver_problemas], [interes_social])`).

### Reglas (Módulo Logic.pl)
Contienen la lógica de inferencia del paradigma declarativo. Procesan el filtrado cruzando las preferencias acumuladas del usuario con las listas de afinidades, aplicando restricciones estrictas para descartar de inmediato aquellas profesiones que contengan aspectos incompatibles expresados negativamente.

## 3. Gramática BNF y Ejemplos de Frases Admitidas

El sistema implementa una gramática libre de contexto mediante reglas DCG (Definite Clause Grammars) en Prolog para analizar oraciones sencillas en español.

```prolog
% Estructura BNF conceptual implementada en BNF.pl:
oracion --> afirmativa.
oracion --> negativa.

afirmativa --> [me], [gusta], sustantivo.
afirmativa --> [disfruto], [trabajar], [con], sustantivo.
negativa   --> [no], [me], [gusta], sustantivo.
```

Ejemplos de frases admitidas:
- Afirmativas: "Me gustan las matemáticas", "Disfruto trabajar con tecnología", "Me gusta resolver problemas", "Me interesa ayudar a las personas".
- Negativas: "No me gusta la tecnología", "No prefiero trabajar con números".

## 4. Explicación del Procedimiento Utilizado para Generar Recomendaciones

El proceso de recomendación sigue un flujo lógico estructurado:

1. Recopilación interactiva: El motor de inferencia realiza preguntas secuenciales en la consola para indagar sobre las áreas de interés del usuario.
2. Traducción gramatical: Cada respuesta ingresada en lenguaje natural es evaluada por el módulo `BNF.pl`. Si la frase no es reconocida, el sistema emite un aviso para solicitar al usuario que reformule su respuesta sin registrar ningún valor incorrecto.
3. Acumulación de estado: Las preferencias reconocidas se clasifican y acumulan internamente diferenciando entre afinidades positivas y restricciones negativas.
4. Inferencia y filtrado: Mediante un recorrido sobre la base de conocimientos de `BD.pl`, el motor valida que la profesión candidata contenga las afinidades respaldadas por el usuario y, de forma crítica, verifica que ninguna de las preferencias negativas del usuario coincida con los aspectos incompatibles de dicha carrera. Si se cumple, se emite la recomendación final o se notifica la ausencia de coincidencias si ningún perfil cumple con los filtros estrictos.

## 5. Casos de Prueba

| Caso de Prueba | Situación y Entradas de Ejemplo | Resultado Esperado | Resultado Obtenido |
| --- | --- | --- | --- |
| 1 | Perfil tecnológico: "Me gustan las matemáticas", "Disfruto trabajar con tecnología", "Me gusta resolver problemas" | Recomendar una profesión compatible con matemáticas, tecnología y resolución de problemas (ej. Ingeniería en Computadores). | Recomendó Ingeniería en Computadores de forma exitosa tras validar los tres hechos positivos. |
| 2 | Perfil social: "Me interesa ayudar a las personas", "Prefiero escuchar a los demás" | Reconocer la preferencia social e interpersonal y recomendar una carrera compatible (ej. Psicología). | Recomendó Psicología exitosamente al cruzar afinidades de interacción social. |
| 3 | Negación de una afinidad: Mantiene el perfil técnico pero sustituye la afinidad tecnológica por: "No me gusta la tecnología" | Reconocer la preferencia negativa, bloquear perfiles tecnológicos (como Ingeniería) y sugerir alternativas viables. | Descartó correctamente Ingeniería en Computadores aplicando la restricción de incompatibilidad y ofreció otra opción afín. |
| 4 | Respuesta no reconocida: Ingresa: "La ventana está abierta"; luego ingresa: "Me gustan las matemáticas" | Solicitar reformulación de la primera frase sin registrarla como válida, y continuar el flujo al recibir la frase correcta. | La gramática rechazó la primera entrada impertinente, solicitó reintentar y procesó con éxito la segunda frase. |
| 5 | Perfil sin coincidencias: Combinación contradictoria o restrictiva de preferencias que no se acopla a ninguna de las 10 profesiones. | Informar de manera controlada que no se dispone de una recomendación compatible, sin colapsar ni contradecir reglas. | El sistema finalizó la ejecución indicando de forma limpia que no se hallaron coincidencias para el perfil provisto. |

## 6. Limitaciones Conocidas y Aportes de cada Integrante

### Limitaciones Conocidas
- El vocabulario en lenguaje natural está acotado estrictamente a las reglas sintácticas definidas en la gramática DCG, por lo que variaciones semánticas complejas o sinónimos no contemplados requerirán reformulación.
- Las asociaciones vocacionales son simulaciones lógicas académicas simplificadas y no equivalen a un dictamen psicológico u orientación profesional real.

### Aportes de cada Integrante
- Claudio Arce Cascante (Encargado de la Base de Conocimientos - BD.pl): Investigación, diseño y codificación en Prolog de la estructura de hechos, afinidades, fortalezas y listas de incompatibilidades para el conjunto de las 10 profesiones requeridas.
- David Solís Méndez (Encargado de la Gramática y Lenguaje - BNF.pl): Desarrollo e implementación de la gramática libre de contexto mediante reglas DCG para el reconocimiento y distinción lógica de frases afirmativas y negativas en español.
- Raul Ramirez Villegas (Encargado del Motor de Inferencia e Interacción - Logic.pl): Programación del ciclo interactivo en la consola, gestión de reintentos ante entradas no reconocidas y estructuración de las reglas lógicas de recomendación y filtrado de restricciones.
