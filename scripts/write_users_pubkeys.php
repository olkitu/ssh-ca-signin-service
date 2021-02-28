<?php

function mysql_connect() {
    require 'config.php';

    try {
        $conn = new PDO("mysql:host=$servername;port=$port;dbname=$database", $username, $password);
        $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
    }
    catch(PDOException $e) {
        echo "Connection failed: ". $e->getMessage();
    }
    return $conn;
}

echo "Run Write Users Pubkeys\n";

/*
* Read All Users and keys
*/

function create_users() {
    $conn = mysql_connect();
    $sql = $conn -> prepare("SELECT username,pubkey from clients");
    $conn = $sql -> execute();
    if ($sql->rowCount()== false) {
        return "No users";
    }
    else {
        while ($row = $sql->fetch()) {
            $username = $row['username'];

            exec('bash /usr/local/bin/create_user.sh '. $username);

            $keyfile = fopen('/home/'.$username.'/.ssh/authorized_keys', 'w');
            fwrite($keyfile,$row['pubkey']);
            fclose($keyfile);

            exec('bash /usr/local/bin/set_users_permissions.sh '. $username);

        }
    }

}

# Run
create_users();

echo "Completed Write Users Pubkeys\n";

?>