<?php
/*
Open connection with PostgreSQL server
*/
function open_pg_connection() {
	include_once('../conf/conf.php');
    
    $connection = "host=".myhost." dbname=".mydb." user=".myuser." password=".mypsw;
    
    return pg_connect ($connection);
    
}

/*
Close connection with PostgreSQL server
*/
function close_pg_connection($db) {
        
    return pg_close ($db);
    
}

/*
check the validity of given credentials
*/
function loginLet($user, $psw) {
    
    $logged = null;

    $db = open_pg_connection();
    
    $sql = "SELECT cdf FROM biblioteca.lettore WHERE cdf = $1 AND pass = $2";

    $params = array(
    	$user,
    	$psw
    );

    $result = pg_prepare($db, "check_user", $sql);
    $result = pg_execute($db, "check_user", $params);

    if($row = pg_fetch_assoc($result)){
    	$logged = $row['cdf'];
    }

    close_pg_connection($db);

    return $logged;
    
}

function loginBib($user, $psw) {
    
    $logged = null;

    $db = open_pg_connection();
    
    $sql = "SELECT cdf FROM biblioteca.bibliotecario WHERE cdf = $1 AND pass = $2";

    $params = array(
    	$user,
    	$psw
    );

    $result = pg_prepare($db, "check_user", $sql);
    $result = pg_execute($db, "check_user", $params);

    if($row = pg_fetch_assoc($result)){
    	$logged = $row['cdf'];
    }

    close_pg_connection($db);

    return $logged;
    
}

function creaUtente($cdf, $nome, $tipo, $psw){
	$db = open_pg_connection();
	$type = 0;
	$n_rit=0;
	if($tipo=='premium'){
		$type=1;
	}
	
	  $sql = "INSERT INTO biblioteca.lettore VALUES ($1,$2,$3,$4,$5)";
    	$params = array(
    		$cdf,
    		$nome,
    		$type,
    		$n_rit,
    		$psw
    	);
	
    	$result = pg_prepare($db, "add_user", $sql);
    	$result = pg_execute($db, "add_user", $params);

    	close_pg_connection($db);

}

function eliminaUtente($cdf){
  $db = open_pg_connection();
  $sql = "DELETE FROM biblioteca.lettore WHERE cdf=$1";
    	$params = array(
    		$cdf
    	);
	
    	$result = pg_prepare($db, "remove_user", $sql);
    	$result = pg_execute($db, "remove_user", $params);

    	close_pg_connection($db);
}

function azzeraRitardi($cdf){
  $db = open_pg_connection();
  $sql = "UPDATE biblioteca.lettore SET n_ritardi=0 WHERE cdf=$1";
    	$params = array(
    		$cdf
    	);
	
    	$result = pg_prepare($db, "zero_ritardi", $sql);
    	$result = pg_execute($db, "zero_ritardi", $params);

    	close_pg_connection($db);
}

function aggiornaPasswordB($cdf, $new1, $new2){
  $db = open_pg_connection();
  $msg = null;
  
  if($new1=$new2){
    $sql = "UPDATE biblioteca.bibliotecario SET pass=$1 WHERE cdf=$2";
    $params = array(
      $new1,
      $cdf
    );
	
    $result = pg_prepare($db, "aggiorna_pass_bib", $sql);
    $result = pg_execute($db, "aggiorna_pass_bib", $params);
    
    $msg="aggiornamento eseguito con successo";
  }else{
    $msg="ERRORE, le password non corrispondono";
  }
  
  close_pg_connection($db);
  return $msg;

}

function aggiungiLibro($isbn,$titolo,$casa_ed,$trama){
  $db=open_pg_connection();
  $msg=null;
  $ok=controllaIsbn($isbn);
  if($ok==0){
    $msg="ISBN non nel formato corretto (xxx-x-xxx-xxxxx-x)";
  }else{
    if ($ok==1){
      $msg="ISBN troppo corto";
    }else{
      if ($ok==2){
        $msg="ISBN troppo lungo" ; 
      }else{
        $sql = "INSERT INTO biblioteca.libro VALUES ($1,$2,$3,$4)";
        $params = array(
          $isbn,
          $titolo,
          $casa_ed,
          $trama
        );
	
        $result = pg_prepare($db, "aggiunta_libro", $sql);
        $result = pg_execute($db, "aggiunta_libro", $params);
      }
    }
  }
  close_pg_connection($db);
  
  return $msg;
}

function controllaIsbn($isbn){
  if(strlen($isbn)<17){
    return 1;
  }else if(strlen($isbn)>17){
    return 2;
  }
  if(preg_match('/^\d{3}-\d{1}-\d{3}-\d{5}-\d{1}$/', $isbn)){
    return 3;
  }
  
  return 0;
}

function generaIdCopia() {
    $lenght=10;
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[random_int(0, $charactersLength - 1)];
    }
    return $randomString;
}
?>
