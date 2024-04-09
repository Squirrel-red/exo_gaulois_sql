------------------------------------------------------------------------------------------------------------
-- Part 1. Sélection et visualisation de données selon les certaines critères
------------------------------------------------------------------------------------------------------------ 

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

-- 7. "Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'." :

SELECT nom_potion, nom_ingredient, cout_ingredient, qte
FROM 	potion
INNER JOIN composer ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON ingredient.id_ingredient = composer.id_ingredient
WHERE nom_potion = 'Santé'

-- 8.  "Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'." :

SELECT p.nom_personnage, SUM(pc.qte) AS nb_casques
FROM personnage p, bataille b, prendre_casque pc
WHERE p.id_personnage = pc.id_personnage
AND pc.id_bataille = b.id_bataille
AND b.nom_bataille = 'Bataille du village gaulois'
GROUP BY p.id_personnage
HAVING nb_casques >= ALL(
  -- >= ALL : vérifie pour chaque ligne d'au dessus (avec nb_casques déjà défini), si nb_casques >= tous les nb_casques redéfinis en sous-requête.
	SELECT SUM(pc.qte)
 	FROM prendre_casque pc, bataille b
 	WHERE b.id_bataille = pc.id_bataille
 	AND b.nom_bataille = 'Bataille du village gaulois'
 	GROUP BY pc.id_personnage
)


-- 9.  "Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur au plus petit)." :
    
SELECT p.nom_personnage, SUM(b.dose_boire) AS doseBue
FROM personnage p
INNER JOIN boire b ON b.id_personnage = p.id_personnage
GROUP BY b.id_personnage
ORDER BY doseBue DESC

-- 10. "Nom de la bataille où le nombre de casques pris a été le plus important." : 

SELECT b.nom_bataille, SUM(pc.qte) AS nbCasques
FROM bataille b
INNER JOIN prendre_casque pc ON b.id_bataille = pc.id_bataille
GROUP BY b.id_bataille
/*idem à l'exo 8 avec condition sur la bataille en moins*/
HAVING SUM(pc.qte) >= ALL (
		SELECT SUM(pc.qte)
		FROM prendre_casque pc
		GROUP BY pc.id_bataille
	)   

-- 11. "Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant)" :

SELECT tc.nom_type_casque, COUNT(c.nom_casque) as nb_type_casques, SUM(c.cout_casque) as cout_casques
FROM casque c
INNER JOIN type_casque tc ON c.id_type_casque = tc.id_type_casque
GROUP BY tc.id_type_casque
ORDER BY nb_type_casques DESC   

-- 12. "Nom des potions dont un des ingrédients est le poisson frais" :

SELECT p.nom_potion
FROM potion p
INNER JOIN composer c ON  c.id_potion = p.id_potion
INNER JOIN ingredient i ON i.id_ingredient = c.id_ingredient
WHERE i.nom_ingredient = 'Poisson frais'

-- 13. "Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois" :

SELECT nom_lieu, COUNT(*) AS nbHabitants
FROM personnage p
INNER JOIN lieu l ON l.id_lieu = p.id_lieu
WHERE NOT l.nom_lieu = 'Village gaulois'
GROUP BY l.id_lieu
HAVING nbHabitants >= ALL(
	SELECT COUNT(*) AS nbHabitans
	FROM personnage p, lieu l
	WHERE l.id_lieu = p.id_lieu
	AND NOT l.nom_lieu = 'Village gaulois'
	GROUP BY l.id_lieu
)


-- 14. "Nom des personnages qui n'ont jamais bu aucune potion" :

SELECT p.nom_personnage 
FROM personnage p
LEFT JOIN boire b ON p.id_personnage = b.id_personnage
WHERE b.id_personnage IS NULL


-- 15. "Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'" :

SELECT p.nom_personnage 
FROM personnage  p
WHERE p.id_personnage NOT IN (
SELECT ab.id_personnage 
FROM autoriser_boire ab
WHERE id_potion = 1
)

----------------------------------------------------------------------------------------------------------------
--- Part 2. Modification de labase de données
----------------------------------------------------------------------------------------------------------------

-- A."Ajoutez le personnage suivant : Champdeblix, agriculteur résidant à la ferme Hantassion de Rotomagus." :

INSERT INTO personnage VALUES (45,'Champdeblix','Ferme Hantassion','indisponible.jpg', 6, 12);
	
-- B."Autorisez Bonemine à boire de la potion magique, elle est jalouse d'Iélosubmarine..." :

INSERT INTO autoriser_boire VALUES (1, 12);
	
-- C. "Supprimez les casques grecs qui n'ont jamais été pris lors d'une bataille." :

DELETE 
FROM casque
WHERE (casque.id_type_casque = 2) AND (casque.id_casque NOT IN 
(SELECT prendre_casque.id_casque FROM prendre_casque))

-- D. "Modifiez l'adresse de Zérozérosix : il a été mis en prison à Condate."

UPDATE personnage
SET adresse_personnage = "Prison", id_lieu = 9
WHERE personnage.id_personnage = 23
	

-- E. "La potion 'Soupe' ne doit plus contenir de persil." :

DELETE c
FROM composer c, potion p, ingredient i
WHERE p.id_potion = c.id_potion
AND i.id_ingredient = c.id_ingredient
AND nom_potion = 'Soupe'
AND nom_ingredient = 'Persil'

-- F. " Obélix s'est trompé : ce sont 42 casques Weisenau, et non Ostrogoths, 
--      qu'il a pris lors de la bataille 'Attaque de la banque postale'. Corrigez son erreur ! " :

UPDATE prendre_casque pc 
SET qte = 42,
	id_casque = (SELECT id_casque FROM casque WHERE nom_casque = 'Weisenau')
WHERE id_personnage = (SELECT id_personnage FROM personnage WHERE nom_personnage = 'Obélix') 
AND id_bataille = (SELECT id_bataille FROM bataille WHERE nom_bataille = 'Attaque de la banque postale')

