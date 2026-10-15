% ===================================================================
% Archivo: BD.pl
% Descripción: Base de conocimientos del sistema experto OrientadorCE.
% ===================================================================

% ===================================================================
% Hechos dinámicos: Permiten registrar las respuestas del usuario 
% durante la conversación en tiempo de ejecución.
% ===================================================================
:- dynamic gusta/1.
:- dynamic no_gusta/1.

% ===================================================================
% Estructura: profesion(Nombre, [Afinidades], [Incompatibilidades]).
% ==================================================================

% 1. Ingeniería en Computadores 
profesion(ingenieria_en_computadores, 
          [matematicas, tecnologia, resolver_problemas], 
          [trabajo_rutinario]).

% 2. Psicología 
profesion(psicologia, 
          [ayudar_personas, escuchar, empatia], 
          [tecnologia, trabajo_aislado]).

% 3. Ingeniería en Sistemas de Producción Animal
profesion(sistemas_de_produccion_animal, 
          [animales, naturaleza, trabajo_aire_libre], 
          [sedentarismo, trabajo_de_oficina]).

% 4. Educación Física y Deportes
profesion(educacion_fisica, 
          [deportes, ensenar, trabajo_aire_libre, liderazgo], 
          [trabajo_de_oficina, sedentarismo]).

% 5. Medicina Veterinaria
profesion(veterinaria, 
          [animales, biologia, resolver_problemas, ciencia], 
          [sangre, poca_paciencia]).

% 6. Arquitectura
profesion(arquitectura, 
          [diseno, dibujo, matematicas, creatividad], 
          [trabajo_monotono]).

% 7. Derecho
profesion(derecho, 
          [lectura, debate, memoria, ayudar_personas], 
          [matematicas, trabajo_fisico]).

% 8. Administración de Empresas
profesion(administracion, 
          [negocios, liderazgo, organizacion, resolver_problemas], 
          [desorden, trabajo_aislado]).

% 9. Periodismo
profesion(periodismo, 
          [escribir, investigar, escuchar, hablar_en_publico], 
          [trabajo_aislado, rutina]).

% 10. Diseño Gráfico
profesion(diseno_grafico, 
          [creatividad, arte, tecnologia, diseno], 
          [matematicas_complejas]).