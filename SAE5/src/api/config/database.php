<?php
class Database {
    private $host;
    private $database_name;
    private $username;
    private $password;
    public $conn;

    public function __construct() {
        // Use environment variables with fallback to default values
        $this->host = $_ENV['MYSQL_HOST'] ?? 'db';
        $this->database_name = $_ENV['MYSQL_DATABASE'] ?? 'LuluLaBDD';
        $this->username = $_ENV['MYSQL_USER'] ?? 'root';
        $this->password = $_ENV['MYSQL_PASSWORD'] ?? 'root';
    }

    public function getConnection() {
        $this->conn = null;
        try {
            $dsn = "mysql:host=" . $this->host . ";dbname=" . $this->database_name;
            $this->conn = new PDO(
                $dsn,
                $this->username,
                $this->password
            );
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->conn->exec("set names utf8mb4");
            return $this->conn;
        } catch(PDOException $exception) {
            // Log the error or handle it appropriately
            error_log("Database Connection Error: " . $exception->getMessage());
            return null;
        }
    }
}