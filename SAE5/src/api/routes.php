<?php
// Active l'affichage des erreurs
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Headers CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Gestion des requêtes OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    require_once __DIR__ . '/config/database.php';
    $database = new Database();
    $db = $database->getConnection();

    if (!$db) {
        throw new Exception('La connexion à la base de données a échoué');
    }

    $method = $_SERVER['REQUEST_METHOD'];

    switch($method) {
        case 'POST':
            $rawData = file_get_contents("php://input");
            if (!$rawData) {
                throw new Exception('Aucune donnée reçue');
            }

            $data = json_decode($rawData);
            if (json_last_error() !== JSON_ERROR_NONE) {
                throw new Exception('Données JSON invalides: ' . json_last_error_msg());
            }

            if (!isset($data->day_of_week) || !isset($data->color) || !isset($data->waypoints)) {
                throw new Exception('Données manquantes dans la requête');
            }

            try {
                $db->beginTransaction();

                // Insérer la route
                $stmt = $db->prepare("INSERT INTO routes (day_of_week, color, created_at) VALUES (?, ?, NOW())");
                $stmt->execute([
                    $data->day_of_week,
                    str_replace('#', '', $data->color)
                ]);
                
                $routeId = $db->lastInsertId();

                // Insérer les waypoints
                $stmt = $db->prepare("
                    INSERT INTO waypoints (route_id, longitude, latitude, position_order, address) 
                    VALUES (?, ?, ?, ?, ?)"
                );
                
                foreach($data->waypoints as $index => $point) {
                    $stmt->execute([
                        $routeId,
                        $point->longitude,
                        $point->latitude,
                        $index,
                        $point->address
                    ]);
                }
                
                $db->commit();
                
                echo json_encode([
                    'status' => 'success',
                    'id' => $routeId,
                    'message' => 'Route créée avec succès'
                ]);
            } catch (Exception $e) {
                $db->rollBack();
                throw $e;
            }
            break;

        case 'GET':
            if(isset($_GET['id'])) {
                $stmt = $db->prepare("
                    SELECT r.*, w.id as waypoint_id, w.longitude, w.latitude, w.position_order, w.address 
                    FROM routes r 
                    LEFT JOIN waypoints w ON r.id = w.route_id 
                    WHERE r.id = ?
                    ORDER BY w.position_order"
                );
                $stmt->execute([$_GET['id']]);
                echo json_encode([
                    'status' => 'success',
                    'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)
                ]);
            } else {
                $stmt = $db->query("SELECT * FROM routes ORDER BY created_at DESC");
                echo json_encode([
                    'status' => 'success',
                    'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)
                ]);
            }
            break;

        default:
            throw new Exception('Méthode HTTP non supportée');
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
}
