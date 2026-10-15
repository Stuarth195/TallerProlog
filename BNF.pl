% =====================================================================
% Archivo: BNF.pl
% Descripcion: Gramatica DCG adaptada a los atomos de la nueva BD.pl
% (Version sin tildes ni enes para evitar errores de sintaxis/encodamiento)
% =====================================================================

% ---------------------------------------------------------------------
% Especificacion de la Gramatica en Notacion BNF:
% ---------------------------------------------------------------------
% <oracion>              ::= <frase_afirmativa> | <frase_negativa>
% <frase_afirmativa>     ::= <polaridad_afirmativa> <objeto>
% <frase_negativa>       ::= <polaridad_negativa> <objeto>
% <polaridad_afirmativa> ::= "me" "gusta" | "me" "gustan" | "disfruto" | "prefiero" | "me" "interesa"
% <polaridad_negativa>   ::= "no" "me" "gusta" | "no" "me" "gustan" | "no" "me" "interesa"
% <objeto>               ::= [articulo] <nombre_interes>
% ---------------------------------------------------------------------

% Regla principal
oracion(afirmacion(Interes)) --> frase_afirmativa(Interes).
oracion(negacion(Interes))  --> frase_negativa(Interes).

frase_afirmativa(Interes) --> polaridad_afirmativa, objeto(Interes).
frase_negativa(Interes)    --> polaridad_negativa, objeto(Interes).

% ---------------------------------------------------------------------
% 1. Polaridades
% ---------------------------------------------------------------------
polaridad_afirmativa --> [me], [gusta].
polaridad_afirmativa --> [me], [gustan].
polaridad_afirmativa --> [disfruto].
polaridad_afirmativa --> [disfruto], [trabajar], [con].
polaridad_afirmativa --> [prefiero].
polaridad_afirmativa --> [me], [interesa].

polaridad_negativa --> [no], [me], [gusta].
polaridad_negativa --> [no], [me], [gustan].
polaridad_negativa --> [no], [me], [interesa].

% ---------------------------------------------------------------------
% 2. Objetos / Intereses (Mapeados exactamente con los atomos de BD.pl)
% ---------------------------------------------------------------------

% Computacion / Matematicas / Ciencias
objeto(matematicas) --> [las], [matematicas].
objeto(matematicas) --> [matematicas].

objeto(tecnologia) --> [la], [tecnologia].
objeto(tecnologia) --> [tecnologia].

objeto(resolver_problemas) --> [resolver], [problemas].
objeto(resolver_problemas) --> [problemas].

objeto(biologia) --> [la], [biologia].
objeto(biologia) --> [biologia].

objeto(ciencia) --> [la], [ciencia].
objeto(ciencia) --> [ciencia].

% Social / Personas
objeto(ayudar_personas) --> [ayudar], [a], [las], [personas].
objeto(ayudar_personas) --> [ayudar], [personas].
objeto(ayudar_personas) --> [personas].

objeto(escuchar) --> [escuchar], [a], [los], [demas].
objeto(escuchar) --> [escuchar].

objeto(empatia) --> [la], [empatia].
objeto(empatia) --> [empatia].

objeto(liderazgo) --> [el], [liderazgo].
objeto(liderazgo) --> [liderazgo].

% Naturaleza / Aire Libre / Animales
objeto(animales) --> [los], [animales].
objeto(animales) --> [animales].

objeto(naturaleza) --> [la], [naturaleza].
objeto(naturaleza) --> [naturaleza].

objeto(trabajo_aire_libre) --> [trabajar], [al], [aire], [libre].
objeto(trabajo_aire_libre) --> [aire], [libre].

% Arte / Diseno / Creatividad
objeto(diseno) --> [el], [diseno].
objeto(diseno) --> [diseno].

objeto(dibujo) --> [el], [dibujo].
objeto(dibujo) --> [dibujo].

objeto(creatividad) --> [la], [creatividad].
objeto(creatividad) --> [creatividad].

objeto(arte) --> [el], [arte].
objeto(arte) --> [arte].

% Otras profesiones (Derecho, Administracion, Periodismo, etc.)
objeto(deportes) --> [los], [deportes].
objeto(deportes) --> [deportes].

objeto(ensenar) --> [ensenar].

objeto(lectura) --> [la], [lectura].
objeto(lectura) --> [lectura].

objeto(debate) --> [el], [debate].
objeto(debate) --> [debate].

objeto(memoria) --> [la], [memoria].
objeto(memoria) --> [memoria].

objeto(negocios) --> [los], [negocios].
objeto(negocios) --> [negocios].

objeto(organizacion) --> [la], [organizacion].
objeto(organizacion) --> [organizacion].

objeto(escribir) --> [escribir].

objeto(investigar) --> [investigar].

objeto(hablar_en_publico) --> [hablar], [en], [publico].