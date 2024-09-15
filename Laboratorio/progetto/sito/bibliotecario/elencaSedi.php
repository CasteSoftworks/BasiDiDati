<?php $g=elencoSede();?>
<div class="tabella">
  <table>
    <thead>
      <tr>
        <th>ID Sede</th>
        <th>Nome Sede</th>
        <th>Indirizzo Sede</th>
        </tr>
    </thead>
    <tbody>
    <?php if ($g){
        foreach ($g as $h){?>
          <tr>
            <td><?php echo htmlspecialchars($h['sede']); ?></td>
            <td><?php echo htmlspecialchars($h['nome']); ?></td>
            <td><?php echo htmlspecialchars($h['indirizzo']); ?></td>
          </tr>
        <?php }
      }else{?>
          <tr>
            <td colspan="2">Nessuna sede trovata</td>
          </tr>
      <?php }?>
    </tbody>
  </table>
</div>
