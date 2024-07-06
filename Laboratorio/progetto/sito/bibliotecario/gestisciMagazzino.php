<?php
  session_start();
  ini_set ("display_errors", "On");
  ini_set("error_reporting", E_ALL);
  include_once ('../lib/functions.php');
  $URI = $_SERVER['REQUEST_URI'];
  $a=elencoMagazzino();
  if(isset($_POST) && isset($_POST['id']) && isset($_POST['dove'])){
        spostaDaMagazzino($_POST['id'], $_POST['dove']);
        header("location:$URI");
        
  }
  if(isset($_POST) && isset($_POST['conf'])){
        $msg=svuotaMagazzino($_POST['conf']);
  }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>GESTIONE MAGAZZINO</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>GESTIONE MAGAZZINO</h1>
  		<div style="overflow-y: scroll; max-height:400px;">
    	<table>
          <thead>
              <tr>
                  <th>ID copia</th>
                  <th>ISBN</th>
                  <th>Titolo</th>
              </tr>
          </thead>
          <tbody>
              <?php if ($a): ?>
                  <?php foreach ($a as $b): ?>
                      <tr>
                          <td><?php echo htmlspecialchars($b['id']); ?></td>
                          <td><?php echo htmlspecialchars($b['isbn']); ?></td>
                          <td><?php echo htmlspecialchars($b['titolo']); ?></td>
                      </tr>
                  <?php endforeach; ?>
              <?php else: ?>
                  <tr>
                      <td colspan="4">Nessuna copia in magazzino</td>
                  </tr>
              <?php endif; ?>
          </tbody>
      </table>
     </div>
    <div class="questionario">
		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
        <legend>Inserire i dati della copia da spostare dal magazzino ad una sede</legend>

        <div>     
            <input type="text" placeholder="id copia" name="id" required>
        </div>
        <div>
            <input type="text" placeholder="dove vuoi registarlo (id sede)" name="dove" required>
        </div>
        <br>
        <button>sposta la copia</button>
      </form>
    </div>
    <div class="questionario">
		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
        <legend>Per svuotare il magazzino scrivere CONFERMO</legend>

        <div>     
            <input type="text" placeholder="scrivi la parola necessaria" name="conf" required>
        </div>
        <br>
        <button>SVUOTA</button>
      </form>
    </div>
    <?php
   if (!empty($msg)) {
      if($msg=='IMPOSSIBILE SVUOTARE IL MAGAZZINO'){
    ?>
        <div class="errore">
          <p><?php echo $msg; ?></p>
        </div>
    <?php
      }else{
    ?>
        <div class="successo">
          <p><?php echo $msg; ?></p>
        </div>
    <?php
      }
    }
    ?>
	<body>
</html>
