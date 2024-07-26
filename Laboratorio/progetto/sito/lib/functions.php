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
esegue il login per il lettore
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
/*
esegue il login per il bibliotecario
*/
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
/*
crea un utente
*/
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
/*
elimina un utente
*/
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
/*
azzera i ritardi di un utente
*/
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
/*
aggiorna la password di un bibliotecario loggato
*/
function aggiornaPasswordB($cdf, $new1, $new2){
  $db = open_pg_connection();
  $msg = null;
  
  if($new1==$new2){
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
/*
aggiunge un ISBN all'elenco degli ISBN
*/
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
          
        $msg="libro aggiunto";
      }
    }
  }  
  close_pg_connection($db);
  return $msg;
}
/*
controlla che l'ISBN rispetti il formato corretto xxx-x-xxx-xxxxx-x
*/
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
/*
aggiunge x copie di un determinato ISBN ad una sede
*/
function aggiungiCopie($isbn,$dove,$quanti){
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
        for($i=1;$i<=$quanti;$i++){
          $db=open_pg_connection();
          $id = generaId(10);
          $sql = "INSERT INTO biblioteca.copia VALUES ($1,$2,$3,$4)";
          $params = array(
            $id,
            $isbn,
            $dove,
            1
          );
    	
          $result = pg_prepare($db, "nuove_copie", $sql);
          $result = pg_execute($db, "nuove_copie", $params);
          close_pg_connection($db);
        }   
        $msg="copie aggiunte";
      }
    }
  }
  return $msg;
}
/*
genera un id casuale da x(input) elementi alfanumerici
*/
function generaId($lung) {
    $caratteri = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $lungCar = strlen($caratteri);
    $idCopia = '';
    for ($i = 0; $i < $lung; $i++) {
        $idCopia .= $caratteri[random_int(0, $lungCar - 1)];
    }
    return $idCopia;
}
/*
rimuove un ISBN dall'elenco
*/
function rimuoviLibro($isbn){
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
        $db=open_pg_connection();
        $sql = "SELECT id FROM biblioteca.copia WHERE libro=$1";
        $params = array(
          $isbn
        );
    	
        $result = pg_prepare($db, "raccolta_id_da_isbn", $sql);
        $result = pg_execute($db, "raccolta_id_da_isbn", $params);
        close_pg_connection($db);
        
        $arr=pg_fetch_all($result);
        if(!empty($arr)){
          foreach ($arr as $elem){
            $db=open_pg_connection();
            $id=$elem['id'];
            $sql = "DELETE FROM biblioteca.prestato WHERE volume=$1";
            $params = array(
              $id
            );
            $result = pg_prepare($db, "regalo_libro", $sql);
            $result = pg_execute($db, "regalo_libro", $params);
            close_pg_connection($db);
          }
        }
        $db=open_pg_connection();
        $sql = "DELETE FROM biblioteca.scritto WHERE libro=$1";
        $params = array(
          $isbn
        );
    	
        $result = pg_prepare($db, "rimozione_scrittura", $sql);
        $result = pg_execute($db, "rimozione_scrittura", $params);
        close_pg_connection($db);
        
        $db=open_pg_connection();
        $sql = "DELETE FROM biblioteca.copia WHERE libro=$1";
        $params = array(
          $isbn
        );
    	
        $result = pg_prepare($db, "rimozione_copie_tot", $sql);
        $result = pg_execute($db, "rimozione_copie_tot", $params);
        close_pg_connection($db);
        
        $db=open_pg_connection();
        $sql = "DELETE FROM biblioteca.libro WHERE isbn=$1";
        $params = array(
          $isbn
        );
    	
        $result = pg_prepare($db, "rimozione_libro", $sql);
        $result = pg_execute($db, "rimozione_libro", $params);
        close_pg_connection($db);
        $msg="libro rimosso";
      }
    }
  }
  return $msg;
}
/*
rimuove una determinata copia
*/
function rimuoviCopia($id){
  $db=open_pg_connection();
  $sql = "DELETE FROM biblioteca.copia WHERE id=$1";
  $params = array(
    $id
  );
    	
  $result = pg_prepare($db, "rimozione_copia", $sql);
  $result = pg_execute($db, "rimozione_copia", $params);
  
  $msg="copia rimossa";
  close_pg_connection($db);
  return $msg;
}
/*
aggiunge una sede
*/
function aggiungiSede($ind,$cit,$nome){
  $db=open_pg_connection();
  $sede=generaId(5);
  $sql = "INSERT INTO biblioteca.biblioteca VALUES ($1,$2,$3,$4)";
  $params = array(
    $sede,
    $ind,
    $cit,
    $nome
  );
    	
  $result = pg_prepare($db, "aggiunta_sede", $sql);
  $result = pg_execute($db, "aggiunta_sede", $params);
  
  $msg="sede aggiunta";
  close_pg_connection($db);
  return $msg;
}

/*
rimuove una sede, ma prima sposta tutte le sue copie alla 00000 (il magazzino)
*/
function rimuoviSede($sede){
  
  if($sede=='00000'){
    $msg="IMPOSSIBILE CANCELLARE IL MAGAZZINO";
  }else{

    $db=open_pg_connection();
    
    $sql = "SELECT id FROM biblioteca.copia WHERE dove=$1";
    $params = array(
      $sede
    );
      	
    $result = pg_prepare($db, "raccolta_info_copie_in_sede", $sql);
    $result = pg_execute($db, "raccolta_info_copie_in_sede", $params);
    
    close_pg_connection($db);  
    $arr=pg_fetch_all($result);
    if(!empty($arr)){
      foreach ($arr as $elem){
        $db=open_pg_connection();
        
        $id=$elem['id'];
        
        $sql = "UPDATE biblioteca.copia SET dove='00000' WHERE id=$1";
        $params = array(
          $id
        );
          	
        $result = pg_prepare($db, "spostamento_in_magazzino", $sql);
        $result = pg_execute($db, "spostamento_in_magazzino", $params);
        
        close_pg_connection($db);
      }
    }
    $db=open_pg_connection();
    $sql = "SELECT id FROM biblioteca.copia c INNER JOIN biblioteca.prestato p ON 
c.id=p.volume WHERE dove=$1";
      	
    $result = pg_prepare($db, "raccolta_info_copie_in_prestito", $sql);
    $result = pg_execute($db, "raccolta_info_copie_in_prestito", array('00000'));
    
    close_pg_connection($db);  
    $arr=pg_fetch_all($result);
    if(!empty($arr)){
      foreach ($arr as $elem){
        $db=open_pg_connection();
        
        $id=$elem['id'];
        
        $sql = "DELETE FROM biblioteca.prestato WHERE volume=$1";
        $params = array(
          $id
        );
          	
        $result = pg_prepare($db, "regalo_libro", $sql);
        $result = pg_execute($db, "regalo_libro", $params);
        
        close_pg_connection($db);
      }
    }
    
    $db=open_pg_connection();
    
    $sql = "DELETE FROM biblioteca.biblioteca where sede=$1";
    $params = array(
      $sede
    );
      	
    $result = pg_prepare($db, "rimozione_sede", $sql);
    $result = pg_execute($db, "rimozione_sede", $params);
  
    $msg="sede rimossa";
    close_pg_connection($db);
  }
  return $msg;
}
/*
aggiorna una sede su indirizzo, città e nome
*/
function aggiornaSede($sede, $indirizzo, $citta, $nome){
  if($sede!='00000'){
    $msg="aggiornati:";
    if($indirizzo!=''){
      $db=open_pg_connection();
      
      $sql = "UPDATE biblioteca.biblioteca SET indirizzo=$1 WHERE sede=$2";
      $params = array(
        $indirizzo,
        $sede
      );
        	
      $result = pg_prepare($db, "aggiornamento_indirizzo", $sql);
      $result = pg_execute($db, "aggiornamento_indirizzo", $params);
      
      close_pg_connection($db);
      $msg.=" indirizzo";
    }
    if($citta!=''){
      $db=open_pg_connection();
      
      $sql = "UPDATE biblioteca.biblioteca SET citta=$1 WHERE sede=$2";
      $params = array(
        $citta,
        $sede
      );
        	
      $result = pg_prepare($db, "aggiornamento_citta", $sql);
      $result = pg_execute($db, "aggiornamento_citta", $params);
      
      close_pg_connection($db);
      $msg.=", città";
    }
    if($nome!=''){
      $db=open_pg_connection();
      
      $sql = "UPDATE biblioteca.biblioteca SET nome=$1 WHERE sede=$2";
      $params = array(
        $nome,
        $sede
      );
        	
      $result = pg_prepare($db, "aggiornamento_nome", $sql);
      $result = pg_execute($db, "aggiornamento_nome", $params);
      
      close_pg_connection($db);
      $msg.=", nome";
    }
  }else{
    $msg="IMPOSSIBILE AGGIORNARE IL MAGAZZINO";
  }
  
  return $msg;
}
/*
chiama la funzione di DB statsede
*/
function statisticheSede(){
  $db=open_pg_connection();
  
  $query = 'SELECT * FROM "biblioteca"."statSedi"';
  $result = pg_prepare($db, "stat_sede", $query);
  $result = pg_execute($db, "stat_sede", array());
  
  close_pg_connection($db);
  
  $arr=pg_fetch_all($result);
  
  return $arr;
}
/*
chiama la funzione di DB ritardiperognisede()
*/
function ritardiSede(){
  $db=open_pg_connection();
  
  $query = 'SELECT * FROM biblioteca.ritardiperognisede()';
  $result = pg_prepare($db, "ritardi_sede", $query);
  $result = pg_execute($db, "ritardi_sede", array());
  
  close_pg_connection($db);
  
  $arr=pg_fetch_all($result);
  
  return $arr;
}

function elencoPrestiti(){
  $db=open_pg_connection();
  
  $query = 'SELECT * FROM biblioteca.prestato';
  $result = pg_prepare($db, "elenca_prestiti", $query);
  $result = pg_execute($db, "elenca_prestiti", array());
  
  close_pg_connection($db);
  
  $arr=pg_fetch_all($result);
  
  return $arr;
}

function restituisciLibro($cdf, $id){
  $db=open_pg_connection();
  
  $query = 'DELETE FROM biblioteca.prestato WHERE persona=$1 and volume=$2';
  
  $params=array(
    $cdf,
    $id
  );
  
  $result = pg_prepare($db, "restituzione_libro", $query);
  $result = pg_execute($db, "restituzione_libro", $params);
  
  close_pg_connection($db);
  
  $msg="restituzione effettuata";
  
  return $msg;
}

function prorogaPrestito($cdf,$id){
  $db=open_pg_connection();
  $trentaGG=date('Y-m-d', strtotime("+30 days"));

  $query = 'UPDATE biblioteca.prestato SET D_FINE=$1 WHERE persona=$2 and volume=$3';
  $params=array(
    $trentaGG,
    $cdf,
    $id
  );
  
  $result = pg_prepare($db, "restituzione_libro", $query);
  $result = pg_execute($db, "restituzione_libro", $params);
  $err=pg_last_error($db);
  
  if(!empty($err)){
    $pos = strrpos($err, "CONTEXT");
    $err=substr($err,0,$pos);
  }
  
  if($result==FALSE){
    $msg=$err;
  }else{
    $msg="proroga effettuata con successo";
  }
  
  close_pg_connection($db);
  
  return $msg;
}

function ricercaIsbn($isbn){
  $db=open_pg_connection();
  
  $query = 'SELECT * FROM biblioteca.cercalibroisbn($1)';
  
  $params=array(
    $isbn
  );
  
  $result = pg_prepare($db, "ricerca_isbn", $query);
  $result = pg_execute($db, "ricerca_isbn", $params);
  
  close_pg_connection($db);
  
  $arr=pg_fetch_all($result);
  
  return $arr;
}

function ricercaTitolo($titolo){
  $db=open_pg_connection();
  
  $query = 'SELECT * FROM biblioteca.cercalibrotitolo($1)';
  
  $params=array(
    $titolo
  );
  
  $result = pg_prepare($db, "ricerca_titolo", $query);
  $result = pg_execute($db, "ricerca_titolo", $params);
  
  close_pg_connection($db);
  
  $arr=pg_fetch_all($result);
  
  return $arr;
}

function prendiPrestito($id,$persona){
  $db=open_pg_connection();
  $msg='';
  $trentaGG=date('Y-m-d', strtotime("+30 days"));
  $sql = "INSERT INTO biblioteca.prestato VALUES ($1,$2,$3)";
  $params = array(
    $persona,
    $id,
    $trentaGG
  );
    	
  $result = pg_prepare($db, "presa_prestito", $sql);
  $result = pg_execute($db, "presa_prestito", $params);
  $err=pg_last_error($db);
  
  if(!empty($err)){
    $pos = strrpos($err, "CONTEXT");
    $err=substr($err,0,$pos);
  }
  
  if($result==FALSE){
    $msg=$err;
  }else{
    $msg="libro preso in prestito con successo";
  }
  
  close_pg_connection($db);
  return $msg;
}

function aggiornaPasswordL($cdf, $new1, $new2){
  $db = open_pg_connection();
  $msg = null;
  
  if($new1==$new2){
    $sql = "UPDATE biblioteca.lettore SET pass=$1 WHERE cdf=$2";
    $params = array(
      $new1,
      $cdf
    );
	
    $result = pg_prepare($db, "aggiorna_pass_let", $sql);
    $result = pg_execute($db, "aggiorna_pass_let", $params);
    
    $msg="aggiornamento eseguito con successo";
  }else{
    $msg="ERRORE, le password non corrispondono";
  }
  
  close_pg_connection($db);
  return $msg;
}

function elencoMagazzino(){
  $db=open_pg_connection();
  
  $query = 'SELECT c.id, l.isbn, l.titolo FROM biblioteca.copia c INNER JOIN biblioteca.libro l on c.libro=l.isbn WHERE c.dove=$1';
  
  
  $result = pg_prepare($db, "recupero_elenco_magazzino", $query);
  $result = pg_execute($db, "recupero_elenco_magazzino", array('00000'));
  
  close_pg_connection($db);
  
  $arr=pg_fetch_all($result);
  
  return $arr;
}

function spostaDaMagazzino($id, $sede){
  $db=open_pg_connection();
  
  $sql = "UPDATE biblioteca.copia SET dove=$1 WHERE id=$2";
  $params = array(
    $sede,
    $id
  );
  
  $result = pg_prepare($db, "spostamento_da_magazzino", $sql);
  $result = pg_execute($db, "spostamento_da_magazzino", $params);
  
  close_pg_connection($db);
}

function svuotaMagazzino($conf){

  if($conf=="CONFERMO"){

    $db=open_pg_connection();
    
    $sql = "DELETE FROM biblioteca.copia WHERE dove=$1";
    
    $result = pg_prepare($db, "spostamento_da_magazzino", $sql);
    $result = pg_execute($db, "spostamento_da_magazzino", array('00000'));
    
    close_pg_connection($db);
    
    $msg="MAGAZZINO SVUOTATO";
  }else{
    $msg="IMPOSSIBILE SVUOTARE IL MAGAZZINO";
  }
  
  return $msg;
}


?>
