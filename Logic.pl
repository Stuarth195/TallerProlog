% =====================================================================
% Archivo: Logic.pl
% Proyecto: OrientadorCE - Sistema experto de orientación vocacional
% Rol del archivo: CONTROLADOR CENTRAL. Orquesta la conversación por
% consola, guarda temporalmente lo que dice el usuario y aplica las
% reglas de inferencia para filtrar y recomendar profesiones.
%
% CÓMO EJECUTARLO (SWI-Prolog):
%   1. Colocar BD.pl, BNF.pl y Logic.pl en la misma carpeta.
%   2. Abrir SWI-Prolog en esa carpeta y consultar:   ?- ['Logic.pl'].
%   3. Iniciar el programa con la consulta:            ?- iniciar_orientador.
%   4. Para terminar antes de tiempo, escribir:        listo

:- encoding(utf8).

% 1. CARGA DE ARCHIVOS

:- consult('BD.pl').
:- consult('BNF.pl').

% 2. MEMORIA TEMPORAL (predicados dinámicos)

% Normalmente los hechos de un programa Prolog son estáticos. Con
% :- dynamic se avisa que estos predicados SÍ pueden modificarse
% mientras el programa corre (con assertz/retractall).
%   gusta(Interes)    -> el usuario expresó una afinidad  ("me gusta X")
%   no_gusta(Interes) -> el usuario expresó un disgusto   ("no me gusta X")
% (BD.pl ya los declara; repetir la declaración es inofensivo y deja
% a Logic.pl autosuficiente.)
:- dynamic gusta/1.
:- dynamic no_gusta/1.

% limpiar_memoria_de_sesion/0
% retractall(Patron) borra TODOS los hechos que unifiquen con el patrón.
% Las variables que empiezan con "_" son variables anónimas con nombre:
% significan "me da igual qué valor tenga", por eso borran cualquier hecho.
% Se llama al inicio para que una sesión no herede datos de la anterior.
limpiar_memoria_de_sesion :-
    retractall(gusta(_InteresCualquieraDeGusto)),
    retractall(no_gusta(_InteresCualquieraDeDisgusto)).

% ---------------------------------------------------------------------
% 3. PREGUNTAS DEL CUESTIONARIO
% ---------------------------------------------------------------------
% Un solo hecho cuyo argumento es una LISTA de preguntas. Guardar las
% preguntas como datos (y no como código) permite recorrerlas con
% recursividad y modificarlas sin tocar la lógica del programa.
% Se redactan con vocabulario que la gramática de BNF.pl sí entiende.
preguntas_del_cuestionario([
    '¿Qué te gusta?',
    '¿Te gustan las matemáticas?',
    '¿Te gusta la tecnología?',
    '¿Te gusta resolver problemas?',
    '¿Te interesa ayudar a las personas?',
    '¿Te gusta escuchar a los demás?',
    '¿Te gustan los animales?',
    '¿Te gusta trabajar al aire libre?',
    '¿Te gusta la creatividad?',
    '¿Te gustan los deportes?',
    '¿Te gusta escribir?'
]).

% ---------------------------------------------------------------------
% 4. PUNTO DE ENTRADA
% ---------------------------------------------------------------------
% iniciar_orientador/0
% Es una CONJUNCIÓN de metas: Prolog las ejecuta de izquierda a derecha y
% sólo continúa a la siguiente si la anterior tuvo éxito (true).
iniciar_orientador :-
    limpiar_memoria_de_sesion,
    mostrar_bienvenida,
    preguntas_del_cuestionario(ListaPreguntas),
    recorrer_preguntas(ListaPreguntas),
    emitir_veredicto_final.

% mostrar_bienvenida/0
% Imprime el saludo. ~n es un salto de línea en format/2.
mostrar_bienvenida :-
    format('~n'),
    mostrar_linea_del_orientador('Hola. Estoy aquí para ayudarte a explorar opciones profesionales.'),
    mostrar_linea_del_orientador('Respóndeme con frases como "Me gusta la tecnología" o "No me gusta la tecnología".'),
    mostrar_linea_del_orientador('Si quieres ver tu recomendación antes de que termine el cuestionario, escribe: listo').

% mostrar_linea_del_orientador(+TextoMensaje)
% format/2 reemplaza cada ~w por el siguiente elemento de la lista.
mostrar_linea_del_orientador(TextoMensaje) :-
    format('OrientadorCE: ~w~n', [TextoMensaje]).

% ---------------------------------------------------------------------
% 5. CICLO DE INTERACCIÓN (RECURSIVIDAD SOBRE LA LISTA DE PREGUNTAS)
% ---------------------------------------------------------------------
% recorrer_preguntas(+ListaPreguntas)
% Recursividad clásica sobre listas, con dos cláusulas:
%   - CASO BASE: lista vacía [] -> no quedan preguntas, termina con éxito.
%   - CASO RECURSIVO: [PreguntaActual | PreguntasRestantes] es la notación
%     "cabeza | cola". Prolog UNIFICA la lista recibida con ese patrón:
%     PreguntaActual toma el primer elemento y PreguntasRestantes el resto.
% El if-then-else ( Condicion -> Entonces ; Sino ) decide si el usuario
% pidió terminar; en ese caso ya no se llama recursivamente.
recorrer_preguntas([]).
recorrer_preguntas([PreguntaActual | PreguntasRestantes]) :-
    preguntar_hasta_obtener_respuesta_valida(PreguntaActual, EstadoDeLaRespuesta),
    (   EstadoDeLaRespuesta == terminar
    ->  true
    ;   recorrer_preguntas(PreguntasRestantes)
    ).

% preguntar_hasta_obtener_respuesta_valida(+TextoPregunta, -EstadoFinal)
% Muestra la pregunta, lee la respuesta y delega en procesar_respuesta/3.
% EstadoFinal será 'aceptada' (se guardó una preferencia) o 'terminar'.
preguntar_hasta_obtener_respuesta_valida(TextoPregunta, EstadoFinal) :-
    mostrar_linea_del_orientador(TextoPregunta),
    leer_respuesta_del_usuario(RespuestaTextoEntrada),
    procesar_respuesta(RespuestaTextoEntrada, TextoPregunta, EstadoFinal).

% leer_respuesta_del_usuario(-RespuestaTextoEntrada)
% read_line_to_string/2 lee una línea completa del teclado como texto.
% Si la entrada se acaba (end_of_file, por ejemplo con una entrada
% redirigida desde un archivo) se interpreta como "listo" para no
% quedar en un ciclo infinito pidiendo reformular.
leer_respuesta_del_usuario(RespuestaTextoEntrada) :-
    format('Usuario: '),
    flush_output,
    read_line_to_string(user_input, LineaLeida),
    (   LineaLeida == end_of_file
    ->  RespuestaTextoEntrada = "listo"
    ;   RespuestaTextoEntrada = LineaLeida
    ).

% procesar_respuesta(+RespuestaTextoEntrada, +TextoPregunta, -EstadoFinal)
% Tres cláusulas que Prolog prueba EN ORDEN. El corte ! ("cut") dice:
% "si llegué hasta aquí, ya elegí esta cláusula; no pruebes las siguientes".
%
% Cláusula 1: el usuario escribió "listo" -> terminar el cuestionario.
procesar_respuesta(RespuestaTextoEntrada, _TextoPregunta, terminar) :-
    es_orden_de_terminar(RespuestaTextoEntrada),
    !.
% Cláusula 2: la frase SÍ fue reconocida por BNF.pl. Sólo entonces se
% guarda en memoria. Si interpretar_respuesta/2 falla, Prolog hace
% backtracking y pasa a la cláusula 3 sin haber guardado nada.
procesar_respuesta(RespuestaTextoEntrada, _TextoPregunta, aceptada) :-
    interpretar_respuesta(RespuestaTextoEntrada, InterpretacionDeRespuesta),
    !,
    registrar_preferencia(InterpretacionDeRespuesta),
    confirmar_preferencia_registrada(InterpretacionDeRespuesta).
% Cláusula 3: frase NO reconocida. No se registra NADA; se pide reformular
% y se vuelve a hacer la misma pregunta (recursividad).
procesar_respuesta(_RespuestaTextoEntrada, TextoPregunta, EstadoFinal) :-
    mostrar_linea_del_orientador('No logré entender tu respuesta. Por favor, reformúlala.'),
    mostrar_linea_del_orientador('Ejemplos: "Me gusta la tecnología", "No me gustan las matemáticas", "Prefiero escuchar a los demás".'),
    preguntar_hasta_obtener_respuesta_valida(TextoPregunta, EstadoFinal).

% es_orden_de_terminar(+RespuestaTextoEntrada)
% Éxito si la respuesta es exactamente la palabra "listo" o "terminar".
% memberchk/2 pregunta "¿está este elemento en la lista?" sin dejar
% alternativas pendientes.
es_orden_de_terminar(RespuestaTextoEntrada) :-
    convertir_texto_a_palabras(RespuestaTextoEntrada, ListaPalabras),
    memberchk(ListaPalabras, [[listo], [terminar]]).

% ---------------------------------------------------------------------
% 6. TRADUCCIÓN DEL TEXTO A UNA ESTRUCTURA (puente hacia BNF.pl)
% ---------------------------------------------------------------------
% BNF.pl no recibe texto plano: recibe una LISTA DE ÁTOMOS, uno por
% palabra. Ejemplo: "Me gusta la tecnología." -> [me, gusta, la, tecnología]

% convertir_texto_a_palabras(+RespuestaTextoEntrada, -ListaPalabras)
%  1. string_lower: pasa todo a minúsculas.
%  2. split_string: corta por espacios/tabuladores y quita signos de
%     puntuación pegados a los bordes de cada palabra (.,;:!?¡¿"'()).
%  3. exclude: descarta cadenas vacías (aparecen con espacios dobles).
%  4. maplist(atom_string, ...): convierte cada cadena en átomo.
convertir_texto_a_palabras(RespuestaTextoEntrada, ListaPalabras) :-
    string_lower(RespuestaTextoEntrada, TextoEnMinusculas),
    split_string(TextoEnMinusculas, " \t", ".,;:!?¡¿\"'()", ListaCadenasConVacias),
    exclude(==(""), ListaCadenasConVacias, ListaCadenasSinVacias),
    maplist(atom_string, ListaPalabras, ListaCadenasSinVacias).

% interpretar_respuesta(+RespuestaTextoEntrada, -InterpretacionDeRespuesta)
% InterpretacionDeRespuesta será afirmacion(Interes) o negacion(Interes)
% (lo que produce oracion//1 de BNF.pl). Si no se reconoce, FALLA.
%
% phrase(Regla, ListaPalabras) ejecuta una regla DCG sobre la lista COMPLETA.
% Se intenta en dos pasadas porque BNF.pl mezcla palabras con tilde
% (biología, diseño, enseñar...) y sin tilde (matematicas, tecnologia...):
%   - Pasada 1: palabras tal como las escribió el usuario.
%   - Pasada 2: palabras sin tildes (y ñ -> n).
% Con "->" se toma la primera interpretación válida y no se prueban más.
interpretar_respuesta(RespuestaTextoEntrada, InterpretacionDeRespuesta) :-
    convertir_texto_a_palabras(RespuestaTextoEntrada, ListaPalabrasOriginales),
    (   phrase(oracion(InterpretacionDeRespuesta), ListaPalabrasOriginales)
    ->  true
    ;   quitar_acentos_de_lista(ListaPalabrasOriginales, ListaPalabrasSinAcentos),
        phrase(oracion(InterpretacionDeRespuesta), ListaPalabrasSinAcentos)
    ).

% quitar_acentos_de_lista(+ListaPalabrasConAcentos, -ListaPalabrasSinAcentos)
% maplist/3 aplica un predicado a cada elemento de una lista y arma la
% lista de resultados (equivale a un "map" de otros lenguajes).
quitar_acentos_de_lista(ListaPalabrasConAcentos, ListaPalabrasSinAcentos) :-
    maplist(quitar_acentos_de_palabra, ListaPalabrasConAcentos, ListaPalabrasSinAcentos).

% quitar_acentos_de_palabra(+PalabraConAcentos, -PalabraSinAcentos)
% atom_chars/2 convierte átomo <-> lista de caracteres, en ambos sentidos.
quitar_acentos_de_palabra(PalabraConAcentos, PalabraSinAcentos) :-
    atom_chars(PalabraConAcentos, ListaCaracteresConAcentos),
    maplist(reemplazar_caracter_acentuado, ListaCaracteresConAcentos, ListaCaracteresSinAcentos),
    atom_chars(PalabraSinAcentos, ListaCaracteresSinAcentos).

% reemplazar_caracter_acentuado(+CaracterOriginal, -CaracterResultante)
% Si existe una equivalencia en la tabla, se usa; si no, el carácter queda igual.
reemplazar_caracter_acentuado(CaracterOriginal, CaracterResultante) :-
    (   equivalencia_sin_acento(CaracterOriginal, CaracterEquivalente)
    ->  CaracterResultante = CaracterEquivalente
    ;   CaracterResultante = CaracterOriginal
    ).

% Tabla de equivalencias: un hecho por carácter acentuado.
equivalencia_sin_acento('á', 'a').
equivalencia_sin_acento('é', 'e').
equivalencia_sin_acento('í', 'i').
equivalencia_sin_acento('ó', 'o').
equivalencia_sin_acento('ú', 'u').
equivalencia_sin_acento('ü', 'u').
equivalencia_sin_acento('ñ', 'n').

% ---------------------------------------------------------------------
% 7. ACUMULACIÓN DE PREFERENCIAS (escritura en memoria dinámica)
% ---------------------------------------------------------------------
% registrar_preferencia(+InterpretacionDeRespuesta)
% Dos cláusulas; Prolog elige cuál usar por UNIFICACIÓN con el argumento:
% afirmacion(...) calza con la primera y negacion(...) con la segunda.
%
% Reglas para mantener la memoria coherente:
%  - Una afirmación borra un posible disgusto previo del mismo interés
%    (la última opinión del usuario manda).
%  - Antes de guardar se revisa si ya existe, para no duplicar.
% assertz(Hecho) agrega el hecho AL FINAL de la base de datos
% (asserta lo agregaría al inicio), conservando el orden de las respuestas.
registrar_preferencia(afirmacion(InteresMencionado)) :-
    retractall(no_gusta(InteresMencionado)),
    (   gusta(InteresMencionado)
    ->  true
    ;   assertz(gusta(InteresMencionado))
    ).
registrar_preferencia(negacion(InteresMencionado)) :-
    retractall(gusta(InteresMencionado)),
    (   no_gusta(InteresMencionado)
    ->  true
    ;   assertz(no_gusta(InteresMencionado))
    ).

% confirmar_preferencia_registrada(+InterpretacionDeRespuesta)
% Eco de lo entendido: permite ver que "me gusta X" y "no me gusta X"
% se interpretan de forma diferente.
confirmar_preferencia_registrada(afirmacion(InteresMencionado)) :-
    nombre_legible(InteresMencionado, TextoLegible),
    format('OrientadorCE: Entendido, te gusta: ~w.~n', [TextoLegible]).
confirmar_preferencia_registrada(negacion(InteresMencionado)) :-
    nombre_legible(InteresMencionado, TextoLegible),
    format('OrientadorCE: Entendido, NO te gusta: ~w.~n', [TextoLegible]).

% nombre_legible(+AtomoConGuionesBajos, -TextoConEspacios)
% atomic_list_concat/3 en modo "dividir": corta el átomo en cada "_" y
% luego lo vuelve a unir con espacios.  resolver_problemas -> resolver problemas
nombre_legible(AtomoConGuionesBajos, TextoConEspacios) :-
    atomic_list_concat(ListaPartes, '_', AtomoConGuionesBajos),
    atomic_list_concat(ListaPartes, ' ', TextoConEspacios).

% ---------------------------------------------------------------------
% 8. MOTOR DE INFERENCIA (filtro lógico sobre BD.pl)
% ---------------------------------------------------------------------
% obtener_gustos_registrados(-ListaGustosUsuario)
% findall(Plantilla, Meta, Lista) recolecta TODAS las soluciones de Meta.
% Aquí junta cada Interes para el que exista un hecho gusta(Interes).
obtener_gustos_registrados(ListaGustosUsuario) :-
    findall(InteresGustado, gusta(InteresGustado), ListaGustosUsuario).

% obtener_disgustos_registrados(-ListaDisgustosUsuario)
obtener_disgustos_registrados(ListaDisgustosUsuario) :-
    findall(InteresRechazado, no_gusta(InteresRechazado), ListaDisgustosUsuario).

% afinidades_coincidentes(+ListaAfinidadesCarrera, +ListaGustosUsuario, -ListaCoincidentes)
% Recolecta las afinidades de la carrera que el usuario también dijo que
% le gustan. La meta (member(...), memberchk(...)) es una conjunción:
%   member/2    recorre una a una las afinidades de la carrera (backtracking);
%   memberchk/2 verifica si esa MISMA variable está en los gustos.
% La variable compartida AfinidadEvaluada es lo que obliga a "coincidir".
afinidades_coincidentes(ListaAfinidadesCarrera, ListaGustosUsuario, ListaCoincidentes) :-
    findall(AfinidadEvaluada,
            (   member(AfinidadEvaluada, ListaAfinidadesCarrera),
                memberchk(AfinidadEvaluada, ListaGustosUsuario)
            ),
            ListaCoincidentes).

% hay_aspecto_incompatible_rechazado(+ListaAspectosIncompatibles, +ListaDisgustosUsuario)
% Éxito si ALGÚN aspecto incompatible de la carrera aparece en los
% disgustos del usuario. Funciona igual que arriba: dos member/2 con la
% misma variable; Prolog prueba combinaciones hasta encontrar una que
% unifique (la primera que encuentre basta para dar éxito).
%
% >>> ÚNICO PUNTO donde se define cuándo una carrera tiene "conflicto". <<<
% >>> Si el equipo cambia el criterio, sólo se modifica este predicado.  <<<
hay_aspecto_incompatible_rechazado(ListaAspectosIncompatibles, ListaDisgustosUsuario) :-
    member(AspectoIncompatible, ListaAspectosIncompatibles),
    member(AspectoIncompatible, ListaDisgustosUsuario).

% profesion_compatible(?CarreraEvaluada, +ListaGustosUsuario, +ListaDisgustosUsuario, -CantidadAfinidadesCoincidentes)
% REGLA CENTRAL. Una profesión es válida si:
%   (1) tiene AL MENOS UNA afinidad que coincide con los gustos, Y
%   (2) NO tiene ningún aspecto incompatible que coincida con los disgustos.
%
% Cómo lo resuelve Prolog:
%  - profesion(CarreraEvaluada, ...) con CarreraEvaluada sin valor hace que
%    Prolog pruebe cada hecho de BD.pl, uno por uno (backtracking).
%  - "ListaAfinidadesCoincidentes \== []" exige al menos una coincidencia.
%  - \+ es NEGACIÓN POR FALLO: \+ Meta tiene éxito si Meta NO se puede
%    demostrar. Es decir, "no existe ninguna coincidencia incompatible".
%  - Si cualquier condición falla, esa carrera se descarta y Prolog pasa
%    a la siguiente.
profesion_compatible(CarreraEvaluada, ListaGustosUsuario, ListaDisgustosUsuario, CantidadAfinidadesCoincidentes) :-
    profesion(CarreraEvaluada, ListaAfinidadesCarrera, ListaAspectosIncompatibles),
    afinidades_coincidentes(ListaAfinidadesCarrera, ListaGustosUsuario, ListaAfinidadesCoincidentes),
    ListaAfinidadesCoincidentes \== [],
    \+ hay_aspecto_incompatible_rechazado(ListaAspectosIncompatibles, ListaDisgustosUsuario),
    length(ListaAfinidadesCoincidentes, CantidadAfinidadesCoincidentes).

% buscar_profesiones_compatibles(+ListaGustosUsuario, +ListaDisgustosUsuario, -ListaRecomendacionesOrdenadas)
% 1. findall junta TODAS las carreras válidas como pares Cantidad-Carrera.
% 2. keysort ordena por la clave (la cantidad) de menor a mayor.
% 3. reverse la invierte: la carrera con MÁS coincidencias queda primero.
% Si ninguna carrera es válida, findall devuelve [] (no falla).
buscar_profesiones_compatibles(ListaGustosUsuario, ListaDisgustosUsuario, ListaRecomendacionesOrdenadas) :-
    findall(CantidadCoincidencias-CarreraValida,
            profesion_compatible(CarreraValida, ListaGustosUsuario, ListaDisgustosUsuario, CantidadCoincidencias),
            ListaParesSinOrdenar),
    keysort(ListaParesSinOrdenar, ListaOrdenadaAscendente),
    reverse(ListaOrdenadaAscendente, ListaRecomendacionesOrdenadas).

% ---------------------------------------------------------------------
% 9. VEREDICTO FINAL
% ---------------------------------------------------------------------
% emitir_veredicto_final/0
% Lee la memoria temporal, ejecuta el motor de inferencia y muestra el
% resultado.
emitir_veredicto_final :-
    obtener_gustos_registrados(ListaGustosUsuario),
    obtener_disgustos_registrados(ListaDisgustosUsuario),
    mostrar_resumen_de_preferencias(ListaGustosUsuario, ListaDisgustosUsuario),
    buscar_profesiones_compatibles(ListaGustosUsuario, ListaDisgustosUsuario, ListaRecomendacionesOrdenadas),
    mostrar_veredicto_final(ListaRecomendacionesOrdenadas, ListaGustosUsuario).

% mostrar_resumen_de_preferencias(+ListaGustosUsuario, +ListaDisgustosUsuario)
mostrar_resumen_de_preferencias(ListaGustosUsuario, ListaDisgustosUsuario) :-
    format('~nOrientadorCE: Esto es lo que registré de tus respuestas:~n'),
    format('   Te gusta:    ~w~n', [ListaGustosUsuario]),
    format('   No te gusta: ~w~n~n', [ListaDisgustosUsuario]).

% mostrar_veredicto_final(+ListaRecomendacionesOrdenadas, +ListaGustosUsuario)
% Se elige la cláusula por la FORMA del primer argumento (unificación):
%  - [] (lista vacía)  -> ninguna profesión pasó el filtro.
%  - [Mejor | Otras]   -> hay al menos una; la cabeza es la mejor.
% Como [] y [Cabeza|Cola] nunca pueden unificar con el mismo valor, las
% dos cláusulas son excluyentes y no hace falta usar corte.
mostrar_veredicto_final([], _ListaGustosUsuario) :-
    mostrar_linea_del_orientador('No dispongo de una recomendación compatible con tus preferencias.'),
    mostrar_linea_del_orientador('Ninguna profesión de mi base de conocimientos coincide con tus gustos sin entrar en conflicto con tus disgustos.').
mostrar_veredicto_final([CantidadCoincidenciasMejor-CarreraMejor | OtrasOpciones], ListaGustosUsuario) :-
    nombre_legible(CarreraMejor, NombreLegibleMejor),
    format('OrientadorCE: Según tus preferencias, te recomiendo ~w.~n', [NombreLegibleMejor]),
    mostrar_motivo_de_recomendacion(CarreraMejor, CantidadCoincidenciasMejor, ListaGustosUsuario),
    mostrar_otras_opciones(OtrasOpciones).

% mostrar_motivo_de_recomendacion(+Carrera, +Cantidad, +ListaGustosUsuario)
% Explica el criterio: cuáles gustos del usuario coinciden con la carrera.
mostrar_motivo_de_recomendacion(CarreraRecomendada, CantidadCoincidencias, ListaGustosUsuario) :-
    profesion(CarreraRecomendada, ListaAfinidadesCarrera, _ListaIncompatiblesNoUsada),
    afinidades_coincidentes(ListaAfinidadesCarrera, ListaGustosUsuario, ListaCoincidentes),
    format('OrientadorCE: Motivo: coincide con ~w de tus gustos ~w y no tiene conflictos con tus disgustos.~n',
           [CantidadCoincidencias, ListaCoincidentes]).

% mostrar_otras_opciones(+OtrasOpciones)
% Recursividad sobre la lista de alternativas (mismo patrón cabeza|cola).
% Si no hay alternativas no imprime nada.
mostrar_otras_opciones([]).
mostrar_otras_opciones([PrimeraAlternativa | AlternativasRestantes]) :-
    mostrar_encabezado_de_alternativas,
    mostrar_lista_de_alternativas([PrimeraAlternativa | AlternativasRestantes]).

mostrar_encabezado_de_alternativas :-
    mostrar_linea_del_orientador('Otras opciones compatibles (de mayor a menor coincidencia):').

mostrar_lista_de_alternativas([]).
mostrar_lista_de_alternativas([CantidadCoincidencias-CarreraAlternativa | AlternativasRestantes]) :-
    nombre_legible(CarreraAlternativa, NombreLegibleAlternativa),
    format('   - ~w (coincidencias: ~w)~n', [NombreLegibleAlternativa, CantidadCoincidencias]),
    mostrar_lista_de_alternativas(AlternativasRestantes).
