<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	$a=ritardiSede();
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>RITARDI TOTALI</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>RITARDI TOTALI</h1>
		<div class="tabella">
		  <table>
        <thead>
            <tr>
                <th>Codice Biblioteca</th>
                <th>Copia in Ritardo</th>
                <th>Lettore che Detiene la Copia</th>
            </tr>
        </thead>
        <tbody>
            <?php if ($a){ ?>
                <?php foreach ($a as $b){ ?>
                    <tr>
                        <td><?php echo htmlspecialchars($b['sede']); ?></td>
                        <td><?php echo htmlspecialchars($b['volume']); ?></td>
                        <td><?php echo htmlspecialchars($b['chi']); ?></td>
                    </tr>
            <?php }
                  }else{ ?>
                <tr>
                    <td colspan="3">Nessun ritardo trovato</td>
                </tr>
            <?php } ?>
        </tbody>
      </table>
    </div>
  <body>
</html>
