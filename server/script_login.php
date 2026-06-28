<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user = $_POST['username'] ?? '';
    $pass = $_POST['password'] ?? '';
    // Credenciales débiles a propósito
    $valid_users = ['admin' => 'secret', 'user' => '1234'];
    if (isset($valid_users[$user]) && $valid_users[$user] === $pass) {
        echo "<h1>Bienvenido $user</h1><p>Acceso concedido.</p>";
    } else {
        echo "<h1>Acceso denegado</h1><p>Credenciales incorrectas.</p>";
    }
} else {
    echo '<form method="post">
        Usuario: <input type="text" name="username"><br>
        Contraseña: <input type="password" name="password"><br>
        <input type="submit" value="Login">
    </form>';
}
?>
