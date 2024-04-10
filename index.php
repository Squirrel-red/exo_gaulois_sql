<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Les gaulois</title>
  <link rel="stylesheet" href="styles.css">
</head>

<?php
try
{
    // On se connecte à MySQL/HeidiSQL
	$mysqlClient = new PDO('mysql:host=localhost;dbname=gaulois;charset=utf8', 'root', '');
}
catch (Exception $e)
{
    // En cas d'erreur, on affiche un message et on arrète tout
    die('Erreur : ' . $e->getMessage());
}
// Si tout va bien, on continue

// On récupère tout le contenu de la table "personnages"
$sqlQueryPersonnages = 'SELECT * FROM personnage';
$personnagesStatement = $mysqlClient->prepare($sqlQueryPersonnages);
$personnagesStatement->execute();
$personnages = $personnagesStatement->fetchAll();
?>

<body>

  <h1>Les gaulois</h1>
  <?php
  // On affiche chaque personnage dans la liste 
  foreach ($personnages as $row) {
  echo "<p>".$row['nom_personnage']."</p>";
  }
  ?>

</body>

</html>