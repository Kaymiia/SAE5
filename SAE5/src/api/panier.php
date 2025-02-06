<?php
ini_set('memory_limit', '256M');

// Désactiver l'affichage des erreurs PHP
ini_set('display_errors', 0);
ini_set('display_startup_errors', 0);
error_reporting(E_ALL);

// En-têtes CORS et type de contenu
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

// Gestionnaire d'erreurs personnalisé
function handleError($errno, $errstr, $errfile, $errline) {
    if (!headers_sent()) {
        header('Content-Type: application/json');
        http_response_code(500);
    }
    
    echo json_encode([
        'status' => 'error',
        'message' => 'Erreur PHP: ' . $errstr,
        'details' => [
            'file' => $errfile,
            'line' => $errline
        ]
    ]);
    exit(1);
}

// Définir le gestionnaire d'erreurs
set_error_handler('handleError');

// Gestionnaire d'exceptions
function handleException($e) {
    if (!headers_sent()) {
        header('Content-Type: application/json');
        http_response_code(500);
    }
    
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage(),
        'details' => [
            'file' => $e->getFile(),
            'line' => $e->getLine()
        ]
    ]);
    exit(1);
}

// Définir le gestionnaire d'exceptions
set_exception_handler('handleException');

// En cas d'erreur fatale
register_shutdown_function(function() {
    $error = error_get_last();
    if ($error !== null && in_array($error['type'], [E_ERROR, E_CORE_ERROR, E_COMPILE_ERROR, E_USER_ERROR])) {
        if (!headers_sent()) {
            header('Content-Type: application/json');
            http_response_code(500);
        }
        
        echo json_encode([
            'status' => 'error',
            'message' => 'Erreur fatale: ' . $error['message']
        ]);
    }
});

require_once __DIR__ . '/config/database.php';

class PanierManager {
    private $conn;

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    // Add a vegetable
    public function addVegetable($data) {
        try {
            $stmt = $this->conn->prepare("
                INSERT INTO legumes 
                (nom, stock, poids_unite, prix_kg, prix_unite) 
                VALUES (?, ?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE 
                stock = ?, poids_unite = ?, prix_kg = ?, prix_unite = ?
            ");
            
            $prix_unite = $data['price_per_kg'] * $data['unit_weight'];
            
            $stmt->execute([
                $data['name'], 
                $data['stock'], 
                $data['unit_weight'], 
                $data['price_per_kg'], 
                $prix_unite,
                // ON DUPLICATE KEY UPDATE values
                $data['stock'], 
                $data['unit_weight'], 
                $data['price_per_kg'], 
                $prix_unite
            ]);
            
            return [
                'status' => 'success', 
                'message' => 'Végétal ajouté/mis à jour avec succès'
            ];
        } catch (PDOException $e) {
            return [
                'status' => 'error', 
                'message' => 'Erreur lors de l\'ajout du végétal: ' . $e->getMessage()
            ];
        }
    }

    // Delete a vegetable
    public function deleteVegetable($name) {
        try {
            $stmt = $this->conn->prepare("DELETE FROM legumes WHERE nom = ?");
            $stmt->execute([$name]);
            
            return [
                'status' => 'success', 
                'message' => 'Végétal supprimé avec succès'
            ];
        } catch (PDOException $e) {
            return [
                'status' => 'error', 
                'message' => 'Erreur lors de la suppression du végétal: ' . $e->getMessage()
            ];
        }
    }

    // Get all vegetables
    public function getAllVegetables() {
        try {
            $stmt = $this->conn->query("SELECT * FROM legumes");
            $vegetables = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            return [
                'status' => 'success', 
                'data' => $vegetables
            ];
        } catch (PDOException $e) {
            return [
                'status' => 'error', 
                'message' => 'Erreur lors de la récupération des végétaux: ' . $e->getMessage()
            ];
        }
    }

    // Reset (clear) all vegetables
    public function resetVegetables() {
        try {
            $stmt = $this->conn->prepare("DELETE FROM legumes");
            $stmt->execute();
            
            return [
                'status' => 'success', 
                'message' => 'Tous les végétaux ont été supprimés'
            ];
        } catch (PDOException $e) {
            return [
                'status' => 'error', 
                'message' => 'Erreur lors de la réinitialisation: ' . $e->getMessage()
            ];
        }
    }

    public function optimiserDistribution() {
        try {
            error_log("Début de l'optimisation");
            
            // Fetch all vegetables
            $stmt = $this->conn->query("SELECT * FROM legumes");
            $legumes = $stmt->fetchAll(PDO::FETCH_ASSOC);
            error_log("Nombre de légumes récupérés: " . count($legumes));
    
            if (empty($legumes)) {
                error_log("Aucun légume trouvé");
                return ['status' => 'success', 'paniers' => [], 'message' => 'Aucun légume disponible'];
            }
    
            // Convert array to match previous implementation
            $legumesData = [];
            foreach ($legumes as $legume) {
                $legumesData[$legume['nom']] = [
                    'nom' => $legume['nom'],
                    'stock' => (int)$legume['stock'],
                    'poids_unite' => (float)$legume['poids_unite'],
                    'prix_kg' => (float)$legume['prix_kg'],
                    'prix_unite' => (float)$legume['prix_unite']
                ];
            }
            error_log("Données des légumes formatées");
    
            // Basket types configuration
            $TYPES_PANIERS = [
                'grand' => ['prix' => 40, 'tolerance' => 3],
                'moyen' => ['prix' => 20, 'tolerance' => 2],
                'petit' => ['prix' => 10, 'tolerance' => 1]
            ];
    
            // Optimization logic
            $resultats = [];
            $stockRestant = $legumesData;
            $numeroFormat = 1;
            
            try {
                // Calculate initial total stock
                $stockInitialTotal = array_sum(array_map(function($leg) {
                    return $leg['stock'] * $leg['poids_unite'];
                }, $legumesData));
                error_log("Stock initial total calculé: " . $stockInitialTotal);
    
                while (true) {
                    $stockRestantTotal = array_sum(array_map(function($leg) {
                        return $leg['stock'] * $leg['poids_unite'];
                    }, $stockRestant));
                    
                    if ($stockRestantTotal <= ($stockInitialTotal * 0.0001)) {
                        error_log("Stock restant trop faible, arrêt de l'optimisation");
                        break;
                    }
                    
                    error_log("Recherche du meilleur panier pour le format " . $numeroFormat);
                    
                    $meilleurType = null;
                    $meilleurPanier = null;
                    $meilleureUtilisation = 0;
                    
                    foreach ($TYPES_PANIERS as $type => $config) {
                        error_log("Test du type de panier: " . $type);
                        $panier = $this->trouverMeilleurPanier($type, $config['prix'], $stockRestant, $stockInitialTotal);
                        if ($panier) {
                            $nbPaniers = $this->calculerNombrePaniers($panier['composition'], $stockRestant);
                            if ($nbPaniers >= 100) {
                                $utilisation = ($panier['poids'] * $nbPaniers) / $stockInitialTotal * 100;
                                if ($utilisation > $meilleureUtilisation) {
                                    $meilleurPanier = $panier;
                                    $meilleurType = $type;
                                    $meilleureUtilisation = $utilisation;
                                }
                            }
                        }
                    }
                    
                    if (!$meilleurPanier) {
                        error_log("Aucun panier standard trouvé, tentative d'optimisation supplémentaire");
                        foreach ($TYPES_PANIERS as $type => $config) {
                            $panierOptimise = $this->peutCreerPaniersSupplémentaires($stockRestant, $config['prix'], $config['tolerance']);
                            if ($panierOptimise) {
                                $meilleurPanier = $panierOptimise;
                                $meilleurType = $type;
                                break;
                            }
                        }
                        if (!$meilleurPanier) {
                            error_log("Aucun panier supplémentaire possible");
                            break;
                        }
                    }
                    
                    $nbPaniers = $this->calculerNombrePaniers($meilleurPanier['composition'], $stockRestant);
                    if ($nbPaniers < 100) {
                        error_log("Nombre de paniers insuffisant");
                        break;
                    }
                    
                    $config = $TYPES_PANIERS[$meilleurType];
                    $typeComplet = $meilleurType . '_' . $numeroFormat;
                    
                    error_log("Création du panier de type: " . $typeComplet);
                    
                    // Construction des détails des légumes
                    $legumes_details = [];
                    foreach ($meilleurPanier['composition'] as $legume => $quantite) {
                        $legumes_details[$legume] = [
                            'quantite' => (int)$quantite,
                            'poids_unite' => (float)$stockRestant[$legume]['poids_unite'],
                            'prix_kg' => (float)$stockRestant[$legume]['prix_kg']
                        ];
                    }
                    
                    $resultats[$typeComplet] = [
                        'composition' => $meilleurPanier['composition'],
                        'nbPaniers' => $nbPaniers,
                        'prixUnitaire' => (float)$config['prix'],
                        'coutUnitaire' => (float)$meilleurPanier['cout'],
                        'poidsUnitaire' => (float)$meilleurPanier['poids'],
                        'margeUnitaire' => (float)($config['prix'] - $meilleurPanier['cout']),
                        'legumes_details' => $legumes_details
                    ];
                    
                    // Mise à jour du stock virtuel
                    foreach ($meilleurPanier['composition'] as $legume => $quantite) {
                        $stockRestant[$legume]['stock'] -= $quantite * $nbPaniers;
                    }
                    
                    error_log("Panier " . $typeComplet . " créé avec succès");
                    $numeroFormat++;
                }
                
                error_log("Optimisation terminée avec succès");
                return [
                    'status' => 'success',
                    'paniers' => $resultats,
                    'stockRestant' => array_map(function($item) {
                        return [
                            'stock' => (int)$item['stock'],
                            'poids_unite' => (float)$item['poids_unite'],
                            'prix_kg' => (float)$item['prix_kg']
                        ];
                    }, $stockRestant)
                ];
                
            } catch (Exception $e) {
                error_log("Erreur dans la boucle d'optimisation: " . $e->getMessage());
                throw $e;
            }
        } catch (Exception $e) {
            error_log("Erreur principale d'optimisation: " . $e->getMessage());
            error_log("Trace: " . $e->getTraceAsString());
            throw new Exception('Erreur lors de l\'optimisation: ' . $e->getMessage());
        }
    }

    
    private function trouverMeilleurPanier($typePanier, $prixCible, $legumes, $stockInitialTotal) {
        $TYPES_PANIERS = [
            'grand' => ['prix' => 40, 'tolerance' => 3],
            'moyen' => ['prix' => 20, 'tolerance' => 2],
            'petit' => ['prix' => 10, 'tolerance' => 1]
        ];
        
        $tolerance = $TYPES_PANIERS[$typePanier]['tolerance'];
        $meilleureComposition = null;
        $meilleurPoids = 0;
        $profit = 0.8;
        $coutCible = $prixCible * $profit;
        
        // Filtrer les légumes avec stock > 0 et les trier par poids total
        $legumesFiltres = array_filter($legumes, function($leg) {
            return $leg['stock'] > 0;
        });

        uasort($legumesFiltres, function($a, $b) {
            return ($b['stock'] * $b['poids_unite']) <=> ($a['stock'] * $a['poids_unite']);
        });

        // Limiter le nombre de légumes à traiter
        $legumesFiltres = array_slice($legumesFiltres, 0, 10, true);

        foreach ($legumesFiltres as $nom => $legume) {
            // Calculer la quantité maximale possible pour ce légume
            $qteMax = min(
                $legume['stock'],
                floor(($coutCible + $tolerance) / ($legume['poids_unite'] * $legume['prix_kg'])),
                5 // Limitation arbitraire pour éviter trop de variations
            );
            
            for ($qte = 1; $qte <= $qteMax; $qte++) {
                $cout = $qte * $legume['poids_unite'] * $legume['prix_kg'];
                if ($cout > $coutCible + $tolerance) break;
                
                $composition = [$nom => $qte];
                $coutTotal = $cout;
                $poidsTotal = $qte * $legume['poids_unite'];
                
                // Si nous sommes déjà dans la plage acceptable avec un seul légume
                if ($coutTotal >= $coutCible - $tolerance && $coutTotal <= $coutCible + $tolerance) {
                    if ($poidsTotal > $meilleurPoids) {
                        $meilleurPoids = $poidsTotal;
                        $meilleureComposition = $composition;
                    }
                    continue;
                }
                
                // Essayer d'ajouter un deuxième légume
                foreach ($legumesFiltres as $nom2 => $legume2) {
                    if ($nom2 === $nom) continue;
                    
                    $qteMax2 = min(
                        $legume2['stock'],
                        floor(($coutCible + $tolerance - $cout) / ($legume2['poids_unite'] * $legume2['prix_kg'])),
                        3 // Limitation plus stricte pour le second légume
                    );
                    
                    for ($qte2 = 1; $qte2 <= $qteMax2; $qte2++) {
                        $coutTotal = $cout + ($qte2 * $legume2['poids_unite'] * $legume2['prix_kg']);
                        
                        if ($coutTotal > $coutCible + $tolerance) break;
                        
                        if ($coutTotal >= $coutCible - $tolerance && $coutTotal <= $coutCible + $tolerance) {
                            $nouveauPoidsTotal = $poidsTotal + ($qte2 * $legume2['poids_unite']);
                            if ($nouveauPoidsTotal > $meilleurPoids) {
                                $meilleurPoids = $nouveauPoidsTotal;
                                $meilleureComposition = $composition + [$nom2 => $qte2];
                            }
                        }
                    }
                }
            }
        }
        
        if ($meilleureComposition) {
            $coutTotal = array_sum(array_map(function($qte, $nom) use ($legumes) {
                return $qte * $legumes[$nom]['poids_unite'] * $legumes[$nom]['prix_kg'];
            }, $meilleureComposition, array_keys($meilleureComposition)));
            
            return [
                'composition' => $meilleureComposition,
                'cout' => $coutTotal,
                'poids' => $meilleurPoids
            ];
        }
        
        return null;
    }

    private function calculerNombrePaniers($composition, $legumes) {
        $nbPaniers = PHP_INT_MAX;
        foreach ($composition as $legume => $quantite) {
            if ($quantite > 0) {
                $possible = floor($legumes[$legume]['stock'] / $quantite);
                $nbPaniers = min($nbPaniers, $possible);
            }
        }
        return $nbPaniers;
    }

    private function peutCreerPaniersSupplémentaires($legumes, $prixCible, $tolerance) {
        $profit = 0.8;
        $coutCible = $prixCible * $profit;
        
        foreach ($legumes as $nom1 => $legume1) {
            if ($legume1['stock'] <= 0) continue;
            
            for ($qte1 = 1; $qte1 <= min($legume1['stock'], 15); $qte1++) {
                $cout1 = $qte1 * $legume1['poids_unite'] * $legume1['prix_kg'];
                if ($cout1 > $coutCible + $tolerance) break;
                
                foreach ($legumes as $nom2 => $legume2) {
                    if ($nom2 === $nom1 || $legume2['stock'] <= 0) continue;
                    
                    for ($qte2 = 1; $qte2 <= min($legume2['stock'], 15); $qte2++) {
                        $coutTotal = $cout1 + ($qte2 * $legume2['poids_unite'] * $legume2['prix_kg']);
                        
                        if ($coutTotal >= $coutCible - $tolerance && $coutTotal <= $coutCible + $tolerance) {
                            $nbPaniers1 = floor($legume1['stock'] / $qte1);
                            $nbPaniers2 = floor($legume2['stock'] / $qte2);
                            $nbPaniersPossibles = min($nbPaniers1, $nbPaniers2);
                            
                            if ($nbPaniersPossibles >= 100) {
                                return [
                                    'composition' => [
                                        $nom1 => $qte1,
                                        $nom2 => $qte2
                                    ],
                                    'cout' => $coutTotal,
                                    'poids' => $qte1 * $legume1['poids_unite'] + $qte2 * $legume2['poids_unite']
                                ];
                            }
                        }
                        
                        if ($coutTotal > $coutCible + $tolerance) break;
                    }
                }
            }
        }
        
        return null;
    }

    public function saveBasket($nom, $type, $details) {
        try {
            $this->conn->beginTransaction();
            
            // Insertion du panier principal
            $stmt = $this->conn->prepare("
                INSERT INTO paniers_sauvegardes 
                (nom, type, poids_total, prix_vente, cout_total, marge) 
                VALUES (?, ?, ?, ?, ?, ?)
            ");
            
            $stmt->execute([
                $nom,
                $type,
                $details['poidsUnitaire'],
                $details['prixUnitaire'],
                $details['coutUnitaire'],
                $details['margeUnitaire']
            ]);
            
            $panierId = $this->conn->lastInsertId();
            
            // Insertion du contenu du panier
            $stmt = $this->conn->prepare("
                INSERT INTO contenu_paniers_sauvegardes 
                (panier_id, legume_nom, quantite, poids_unite, prix_kg) 
                VALUES (?, ?, ?, ?, ?)
            ");
            
            foreach ($details['composition'] as $legume => $quantite) {
                if (!isset($details['legumes_details'][$legume])) {
                    throw new Exception("Détails manquants pour le légume: $legume");
                }
                
                $legume_details = $details['legumes_details'][$legume];
                
                $stmt->execute([
                    $panierId,
                    $legume,
                    $quantite,
                    $legume_details['poids_unite'],
                    $legume_details['prix_kg']
                ]);
            }
            
            $this->conn->commit();
            return [
                'status' => 'success',
                'message' => 'Panier sauvegardé avec succès'
            ];
        } catch (Exception $e) {
            $this->conn->rollBack();
            error_log("Erreur sauvegarde panier: " . $e->getMessage());
            error_log("Details reçus: " . print_r($details, true));
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }

    public function getSavedBaskets() {
        try {
            $stmt = $this->conn->query("SELECT * FROM paniers_sauvegardes ORDER BY date_creation DESC");
            $baskets = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            return [
                'status' => 'success',
                'baskets' => $baskets
            ];
        } catch (Exception $e) {
            return [
                'status' => 'error',
                'message' => 'Erreur lors de la récupération des paniers: ' . $e->getMessage()
            ];
        }
    }

    public function getBasketDetails($id) {
        try {
            // Récupérer les informations du panier
            $stmt = $this->conn->prepare("SELECT * FROM paniers_sauvegardes WHERE id = ?");
            $stmt->execute([$id]);
            $panier = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$panier) {
                return [
                    'status' => 'error',
                    'message' => 'Panier non trouvé'
                ];
            }
            
            // Récupérer le contenu du panier
            $stmt = $this->conn->prepare("SELECT * FROM contenu_paniers_sauvegardes WHERE panier_id = ?");
            $stmt->execute([$id]);
            $contenu = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            return [
                'status' => 'success',
                'basket' => $panier,
                'contenu' => $contenu
            ];
        } catch (Exception $e) {
            return [
                'status' => 'error',
                'message' => 'Erreur lors de la récupération des détails du panier: ' . $e->getMessage()
            ];
        }
    }

    public function deleteBasket($id) {
        try {
            $stmt = $this->conn->prepare("DELETE FROM paniers_sauvegardes WHERE id = ?");
            $stmt->execute([$id]);
            
            return [
                'status' => 'success',
                'message' => 'Panier supprimé avec succès'
            ];
        } catch (Exception $e) {
            return [
                'status' => 'error',
                'message' => 'Erreur lors de la suppression du panier: ' . $e->getMessage()
            ];
        }
    }
}

// Handle API routing
// Remplacez la section de routage à la fin du fichier par ceci :

try {
    $panierManager = new PanierManager();
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'POST':
            $rawInput = file_get_contents('php://input');
            $data = json_decode($rawInput, true);
            
            if (!isset($data['action'])) {
                throw new Exception('Aucune action spécifiée');
            }
            
            switch ($data['action']) {
                case 'add':
                    if (!isset($data['name']) || !isset($data['stock']) || 
                        !isset($data['unit_weight']) || !isset($data['price_per_kg'])) {
                        throw new Exception('Données incomplètes pour ajouter un végétal');
                    }
                    $result = $panierManager->addVegetable($data);
                    break;
                
                case 'delete':
                    if (!isset($data['name'])) {
                        throw new Exception('Nom du végétal requis pour la suppression');
                    }
                    $result = $panierManager->deleteVegetable($data['name']);
                    break;
                
                case 'reset':
                    $result = $panierManager->resetVegetables();
                    break;
                
                case 'optimize':
                    $result = $panierManager->optimiserDistribution();
                    break;

                case 'save_basket':
                    if (!isset($data['nom']) || !isset($data['type']) || !isset($data['details'])) {
                        throw new Exception('Données manquantes pour la sauvegarde du panier');
                    }
                    $result = $panierManager->saveBasket($data['nom'], $data['type'], $data['details']);
                    break;
                
                case 'delete_basket':
                    if (!isset($data['id'])) {
                        throw new Exception('ID du panier requis pour la suppression');
                    }
                    $result = $panierManager->deleteBasket($data['id']);
                    break;
                
                default:
                    throw new Exception('Action non reconnue');
            }
            break;

        case 'GET':
            if (isset($_GET['action'])) {
                switch ($_GET['action']) {
                    case 'get_saved_baskets':
                        $result = $panierManager->getSavedBaskets();
                        break;
                        
                    case 'get_basket_details':
                        if (!isset($_GET['id'])) {
                            throw new Exception('ID du panier manquant');
                        }
                        $result = $panierManager->getBasketDetails($_GET['id']);
                        break;
                        
                    default:
                        $result = $panierManager->getAllVegetables();
                }
            } else {
                $result = $panierManager->getAllVegetables();
            }
            break;
            
        default:
            throw new Exception('Méthode HTTP non supportée');
    }
    
    echo json_encode($result);

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}