<?php 
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('lib/functions.php'); 

    /*
     * Si inserisca il codice necessario per gestire il login degli utenti.
     * Solo gli utenti con credenziali valide possono accedere alle funzionalità dell'applicazione.
     */
    $logged = null;
    $type = null;

    session_start();

    // controlla il login
    $error_msg = '';
    if(isset($_POST) && isset($_POST['usr']) && isset($_POST['psw'])){
        $logged = loginBib($_POST['usr'], $_POST['psw']);
        if (is_null($logged)) {
            // utente non trovato
            $error_msg = 'Credenziali errate. Ripetere il login';
        }
     }

    // imposta la variabile $logges se esiste una sessione aperta
    if(isset($_SESSION['user'])){
        $logged = $_SESSION['user'];
    }
    
    // aggiorna la variabile di sessione
    if(isset($logged)) {
        $_SESSION['user'] = $logged;
    }

    // inizializza $logged se l'utente fa logout
    if(isset($_GET) && isset($_GET['log']) && $_GET['log'] == 'del'){
        unset($_SESSION['user']);
        $logged = null;
    }
?>
<!DOCTYPE html>
<html>
    <head>
        <?php include_once ('lib/header.php'); ?>
        <title>
        HOMEPAGE
        </title>
    </head>
    <body>
    <div>
    <?php
    if (isset($logged)) {
        $logout_link = $_SERVER['PHP_SELF'] . "?log=del";
    ?>
    <div>
    <p>
        <?php echo("Benvenuto $logged ($type)"); ?> - 
        <a href="<?php echo($logout_link); ?>">Logout</a> 
    </p>
    </div>
    <div>
    <?php
    }
    ?>
    </div>
    <?php
      

    /*
     * Si visualizzi qui il form di login quando il login non è stato effettuato
     */
    if(!isset($logged)) {
      include_once("lib/navigation.php");
    ?>

    <div>
    <div>
    <form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
        <legend>Inserisci le credenziali</legend>

        <div>     
            <input type="text" placeholder="username" name="usr">
        </div>
        <div>
            <input type="password" placeholder="password" name="psw">
        </div>
        <br>
        <button>Esegui il login</button>
    </form>
    <?php
    if (!empty($error_msg)) {
    ?>
    <div>
        <p><?php echo $error_msg; ?></p>
    </div>
    <?php 
    }
    }else{
      include_once("bibliotecario.php");
      }
    ?>    
    </div>
    </div>
  </body>
</html>
