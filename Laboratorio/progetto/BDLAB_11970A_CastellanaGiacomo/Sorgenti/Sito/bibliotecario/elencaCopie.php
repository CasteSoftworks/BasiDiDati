<?php $e=elencoCopie();?>
<div class="tabella">
  <table>
    <thead>
      <tr>
        <th>ID Copia</th>
        <th>Biblioteca</th>
        </tr>
    </thead>
    <tbody>
    <?php if ($e){
        foreach ($e as $f){?>
          <tr>
            <td><?php echo htmlspecialchars($f['id']); ?></td>
            <td><?php echo htmlspecialchars($f['dove']); ?></td>
          </tr>
        <?php }
      }else{?>
          <tr>
            <td colspan="2">Nessuna copia trovata</td>
          </tr>
      <?php }?>
    </tbody>
  </table>
</div>
