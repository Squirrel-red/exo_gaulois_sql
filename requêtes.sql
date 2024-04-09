
-- 1 "Nom des lieux qui finissent par 'um'" :

SELECT nom_lieu 
FROM lieu 
WHERE nom_lieu 
LIKE '%um'

-- 2 "Nombre de personnages par lieu (trié par nombre de personnages décroissant)" :
SELECT nom_lieu, COUNT(personnage.id_lieu) as nbPersonnages
FROM lieu
INNER JOIN personnage ON personnage.id_lieu = lieu.id_lieu
GROUP BY lieu.id_lieu
ORDER BY nbPersonnages DESC

-- 3 "Nom des personnages + spécialité + adresse et lieu d 'habitation, triés par lieu puis par nom de personnage ":

SELECT nom_personnage, specialite.nom_specialite AS specialite, adresse_personnage, lieu.nom_lieu
FROM personnage 
INNER JOIN specialite 
ON personnage.id_specialite = specialite.id_specialite
INNER JOIN lieu
ON personnage.id_lieu = lieu.id_lieu
ORDER BY nom_lieu, nom_personnage

-- 4 "Nom des spécialités avec nombre de personnages par spécialité (trié par nombre de personnages décroissant)" :

SELECT nom_specialite, COUNT(personnage.nom_personnage) AS nbPersonnages
FROM specialite
INNER JOIN personnage ON specialite.id_specialite = personnage.id_specialite
GROUP BY specialite.id_specialite
ORDER BY nbPersonnages DESC

-- 5 "Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne (dates affichées au format jj/mm/aaaa) ":

SELECT nom_bataille, lieu.nom_lieu,
DATE_FORMAT(date_bataille, "%d/%m/%Y") AS date
FROM bataille
INNER JOIN lieu ON lieu.id_lieu = bataille.id_lieu
ORDER BY date_bataille DESC

-- 6. "Nom des potions + coût de réalisation de la potion (trié par coût décroissant)" :

SELECT nom_potion, SUM(cout_ingredient * qte) AS cout_potion
FROM 	potion
INNER JOIN composer ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON ingredient.id_ingredient = composer.id_ingredient
GROUP BY composer.id_potion
ORDER BY cout_potion DESC