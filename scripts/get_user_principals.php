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

function get_principal_name($id) {
    $conn = mysql_connect();
    $sql = $conn -> prepare("SELECT name from principals where id=?");
    $sql -> execute([$id]);
    $result = $sql->fetch(PDO::FETCH_ASSOC);
    if($sql->rowCount() > 0) {
        return $result['name'];
    }
    else {
        return false;
    }
}

function get_user_principals($username) {
    $conn = mysql_connect();
    $sql = $conn -> prepare("SELECT principals from clients where username=?");
    $sql -> execute([$username]);
    $result = $sql->fetch(PDO::FETCH_ASSOC);
    if($sql->rowCount() > 0) {
        return $result['principals'];
    }
    else {
        return false;
    }
}

$param = getopt(null, ["username:"]);

if(!$param || $param['username'] == "") {
    echo "Usage: get_user_principals.php --username=Username";
    exit;
}
$principals = explode(",", get_user_principals($param["username"]));
$principal_names = array();
foreach($principals as $key) {
    array_push($principal_names, get_principal_name($key));
}

echo implode(",", $principal_names);
?>