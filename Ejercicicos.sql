--LIBROS
--Obtener todos los libros escritos por autores que cuenten con un seudónimo.
SELECT libros.titulo, libros.autor_id 
FROM libros
INNER JOIN autores ON autores.autor_id = libros.autor_id
        AND autores.seudonimo IS NOT NULL;


--Obtener el título de todos los libros publicados en el año actual cuyos autores poseen un pseudónimo.
SELECT libros.titulo, libros.autor_id 
FROM libros
INNER JOIN autores ON autores.autor_id = libros.autor_id
        AND autores.seudonimo IS NOT NULL
        AND libros.fecha_publicacion = CURDATE();

--Obtener todos los libros escritos por autores que cuenten con un seudónimo y que hayan nacido ante de 1965.
SELECT libros.titulo, libros.autor_id 
FROM libros
INNER JOIN autores ON autores.autor_id = libros.autor_id
        AND autores.seudonimo IS NOT NULL
        AND YEAR(autores.fecha_nacimiento) = '1965';

--Colocar el mensaje no disponible a la columna descripción, en todos los libros publicados antes del año 2000.
UPDATE libros SET descripcion = 'no disponible' 
WHERE YEAR(fecha_publicacion) < '2000';

--Obtener la llave primaria de todos los libros cuya descripción sea diferente de no disponible.
SELECT libro_id, descripcion FROM libros WHERE descripcion NOT LIKE 'no disponible';

--Obtener el título de los últimos 3 libros escritos por el autor con id 2.
SELECT titulo, autor_id FROM libros WHERE autor_id = 2 LIMIT 3;

--Obtener en un mismo resultado la cantidad de libros escritosnpor autores con seudónimo y sin seudónimo.
SET @conSeu=(
SELECT COUNT(*) FROM libros
INNER JOIN autores ON autores.autor_id = libros.autor_id
    AND autores.seudonimo IS NOT NULL
);

SET @sinSeu=(
SELECT COUNT(*) FROM libros
INNER JOIN autores ON autores.autor_id = libros.autor_id
    AND autores.seudonimo IS NULL
);
        
SELECT @conSeu AS con_seudonimo, @sinSeu AS sin_seudonimo;
            --otra forma
CREATE TABLE conteo_seudonimo(
    con_seudonimo INT,
    sin_seudonimo INT
);

INSERT INTO conteo_seudonimo VALUES (@conSeu, @sinSeu);

SELECT * FROM conteo_seudonimo;

--Obtener la cantidad de libros publicados entre enero del año 2000 y enero del año 2005.

SELECT COUNT(*) FROM libros 
WHERE fecha_publicacion BETWEEN '2000-01-01' AND '2005-01-01';

--Obtener el título y el número de ventas de los cinco libros más vendidos.
SELECT titulo, ventas FROM libros ORDER BY ventas DESC LIMIT 5;

--Obtener el título y el número de ventas de los cinco libros más vendidos de la última década.
SELECT titulo, ventas, YEAR(fecha_publicacion) FROM libros 
WHERE YEAR(fecha_publicacion)>(YEAR(CURDATE())-10)
ORDER BY ventas DESC LIMIT 5;

--Obtener la cantidad de libros vendidos por los autores con id 1, 2 y 3.
SELECT autor_id AS autor, ventas FROM libros WHERE
autor_id=1 OR autor_id=2 OR autor_id=3
GROUP BY autor_id;

--Obtener el título del libro con más páginas
SELECT titulo FROM libros ORDER BY paginas DESC LIMIT 1;

--Obtener todos los libros cuyo título comience con la palabra “La”.
SELECT titulo FROM libros WHERE titulo LIKE 'La%';

--Obtener todos los libros cuyo título comience con la palabra “La” y termine con la letra “a”.
SELECT titulo FROM libros WHERE titulo LIKE 'La%' AND titulo LIKE '%a';

--Establecer el stock en cero a todos los libros publicados antes del año de 1995
UPDATE libros SET stock = 0 WHERE YEAR(fecha_publicacion)<1995;

--Mostrar el mensaje Disponible si el libro con id 1 posee más de 5 ejemplares en stock, en caso contrario mostrar el mensaje No disponible.
SELECT IF(stock>5, 'Disponile', 'No disponible') FROM libros WHERE libro_id=1;

--Obtener el título los libros ordenador por fecha de publicación del más reciente al más viejo.
SELECT titulo, fecha_publicacion FROM libros ORDER BY fecha_publicacion DESC;


--AUTORES
--Obtener el nombre de los autores cuya fecha de nacimiento sea posterior a 1950
SELECT nombre, YEAR(fecha_nacimiento) FROM autores WHERE YEAR(fecha_nacimiento) > '1950';

--Obtener el nombre completo y la edad de todos los autores.
ALTER TABLE autores ADD edad INT UNSIGNED;

UPDATE autores SET edad = (YEAR(CURDATE())-YEAR(fecha_nacimiento));

SELECT CONCAT(nombre,' ',apellido) AS nombre_completo, edad FROM autores;

--Obtener el nombre completo de todos los autores cuyo último libro publicado sea posterior al 2005
SELECT DISTINCT CONCAT(nombre,' ',apellido) FROM autores
INNER JOIN libros ON libros.autor_id=autores.autor_id 
AND YEAR(libros.fecha_publicacion) > '2005';

--Obtener el id de todos los escritores cuyas ventas en sus libros superen el promedio.
SELECT autor_id, SUM(ventas) FROM libros GROUP BY autor_id HAVING SUM(ventas) > (SELECT AVG(ventas) from libros);

--Obtener el id de todos los escritores cuyas ventas en sus libros sean mayores a cien mil ejemplares.
SELECT autor_id, SUM(ventas) FROM libros GROUP BY autor_id HAVING SUM(ventas) > 100000;

--FUNCIONES
--Crear una función la cual nos permita saber si un libro es candidato a préstamo o no. Retornar “Disponible” si el libro posee por lo menos un ejemplar en stock, en caso contrario retornar “No disponible.”

DELIMITER //

CREATE FUNCTION libro_disponible(libro_idX INT)
RETURNS VARCHAR(20)
BEGIN
    SET @salida = (SELECT IF(stock > 0,"Disponible", "No disponible") FROM libros WHERE libro_id = libro_idX);
    RETURN @salida;
END//

DELIMITER ;

SELECT libro_disponible(1);