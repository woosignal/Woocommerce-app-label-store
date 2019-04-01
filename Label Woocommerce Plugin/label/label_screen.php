<!DOCTYPE html>
<html lang="en">
<head>
  <title>Label</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">

  <!-- DATATABLES -->
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
  <script type="text/javascript" charset="utf8" src="//cdn.datatables.net/1.10.15/js/jquery.dataTables.js"></script>
  <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.15/css/jquery.dataTables.css">

  <!-- DIALOG -->
  <link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
  <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>

  <style type="text/css">
  
  #label_users tbody tr {
    cursor: pointer;
  }

</style>

</head>
<body>

  <div class="container">

    <br>

    <ul class="nav nav-tabs">
      <li class="active"><a data-toggle="tab" href="#home">Users</a></li>
      <li><a data-toggle="tab" href="#menu2">About</a></li>
    </ul>

    <div class="tab-content">
      <div id="home" class="tab-pane fade in active">

        <h3>Label - Users</h3>

        <table id="label_users" class="display" cellspacing="0" width="100%">
          <thead>
            <tr>
              <th>ID</th>
              <th>First name</th>
              <th>Last name</th>
              <th>Email</th>
              <th>Date Joined</th>
            </tr>
          </thead>
          <tfoot>
            <tr>
             <th>ID</th>
             <th>First name</th>
             <th>Last name</th>
             <th>Email</th>
             <th>Date Joined</th>
           </tr>
         </tfoot>
         <tbody>
          <?php 

          $qGetTable = $wpdb->get_results("SELECT ID,user_registered,user_email FROM {$wpdb->users}");

          foreach ($qGetTable as $user)
          {
            $qGetUser = $wpdb->get_results("SELECT user_id,meta_key,meta_value FROM {$wpdb->usermeta} WHERE ({$wpdb->usermeta}.meta_key = 'first_name' AND {$wpdb->usermeta}.user_id = '$user->ID' OR {$wpdb->usermeta}.meta_key = 'last_name' AND {$wpdb->usermeta}.user_id = '$user->ID')");
            
            $userMeta = array();
            foreach ($qGetUser as $a) {
              $userMeta[$a->meta_key] = $a->meta_value;
            }

            echo "<tr>";
            echo "<td>" . $user->ID . "</td>";
            echo "<td>" . $userMeta["first_name"] . "</td>";
            echo "<td>" . $userMeta["last_name"] . "</td>";
            echo "<td>" . $user->user_email . "</td>";
            echo "<td>" . $user->user_registered . "</td>";
            echo "</tr>";
          }

          ?>
        </tbody>
      </table>

      <!-- DIALOG -->
      <div id="dialog" title="Basic dialog">
        <div class="container">
        </div>
      </div>

    </div>
  
    <div id="menu2" class="tab-pane fade">
      <h1>Label WooCommerce Plugin</h1>
      <p>Author: Anthony Gordon</p>
      <p>Support: <a href="mailto:support@woosignal.com">support@woosignal.com</a></p>
      <br>
      <b>Website</b>
      <br>
      - <a href="https://woosignal.com">WooSignal</a>
    </div>
  </div>
</div>

<script>
  $(document).ready(function() {
    $('#label_users').DataTable();

    var table = $('#label_users').DataTable();

    $('#label_users tbody').on('click', 'tr', function () {
      if ( $(this).hasClass('selected')) {
        $(this).removeClass('selected');
      } else {
        table.$('tr.selected').removeClass('selected');
        $(this).addClass('selected');
      }
    });

    $('#button').click( function () {
      table.row('.selected').remove().draw( false );
    });
  });

</script>

</body>

</html>