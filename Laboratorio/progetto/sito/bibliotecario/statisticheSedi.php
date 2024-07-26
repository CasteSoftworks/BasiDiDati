<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	$a=statisticheSede();
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>STATISTICHE SEDI</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>STATISTICHE SEDI</h1>
		<div class="tabella">
  		<table>
          <thead>
              <tr>
                  <th>Codice Biblioteca</th>
                  <th>Numero Copie in Sede</th>
                  <th>Numero Isbn in Sede</th>
                  <th>Numero Prestiti Attivi in Sede</th>
              </tr>
          </thead>
          <tbody>
              <?php if ($a){
                  php foreach ($a as $b){?>
                      <tr>
                          <td><?php echo htmlspecialchars($b['dove']); ?></td>
                          <td><?php echo htmlspecialchars($b['qid']); ?></td>
                          <td><?php echo htmlspecialchars($b['qis']); ?></td>
                          <td><?php echo htmlspecialchars($b['qpr']); ?></td>
                      </tr>
                  <?php}
              }else{?>
                  <tr>
                      <td colspan="4">Nessuna statistica trovata</td>
                  </tr>
              <?php}?>
          </tbody>
      </table>
    </div>
	<body>
</html>
