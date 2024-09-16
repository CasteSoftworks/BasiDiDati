<?php $a=elencoAutori();?>
<div class="tabella">
  <table>
    <thead>
      <tr>
        <th>Codice Autore</th>
        <th>Nome Autore</th>
        </tr>
    </thead>
    <tbody>
    <?php if ($a){
        foreach ($a as $b){?>
          <tr>
            <td><?php echo htmlspecialchars($b['id']); ?></td>
            <td><?php echo htmlspecialchars($b['nome']); ?></td>
          </tr>
        <?php }
      }else{?>
          <tr>
            <td colspan="2">Nessun autore trovato</td>
          </tr>
      <?php }?>
    </tbody>
  </table>
</div>
