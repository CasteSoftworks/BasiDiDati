<?php $c=elencoISBN();?>
<div class="tabella">
  <table>
    <thead>
      <tr>
        <th>Codice ISBN</th>
        <th>Titolo Libro</th>
        </tr>
    </thead>
    <tbody>
    <?php if ($c){
        foreach ($c as $d){?>
          <tr>
            <td><?php echo htmlspecialchars($d['isbn']); ?></td>
            <td><?php echo htmlspecialchars($d['titolo']); ?></td>
          </tr>
        <?php }
      }else{?>
          <tr>
            <td colspan="2">Nessun libro trovato</td>
          </tr>
      <?php }?>
    </tbody>
  </table>
</div>
