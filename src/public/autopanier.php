<?php
session_start();

if (!isset($_SESSION['legumes'])) {
    $_SESSION['legumes'] = [];
}

// Configuration des types de paniers
$TYPES_PANIERS = [
    'grand' => ['prix' => 40, 'tolerance' => 3],
    'moyen' => ['prix' => 20, 'tolerance' => 2],
    'petit' => ['prix' => 10, 'tolerance' => 1]
];

// Traitement des formulaires
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['action'])) {
        switch ($_POST['action']) {
            case 'ajouter':
                $poids_unite = floatval($_POST['poids_unite']);
                $prix_kg = floatval($_POST['prix_kg']);
                $nouveau_legume = [
                    'nom' => $_POST['nom'],
                    'stock' => intval($_POST['stock']),
                    'poids_unite' => $poids_unite,
                    'prix_kg' => $prix_kg,
                    'prix_unite' => $prix_kg * $poids_unite
                ];
                $_SESSION['legumes'][$_POST['nom']] = $nouveau_legume;
                break;
            case 'supprimer':
                if (isset($_POST['nom']) && isset($_SESSION['legumes'][$_POST['nom']])) {
                    unset($_SESSION['legumes'][$_POST['nom']]);
                }
                break;
            case 'reset':
                $_SESSION['legumes'] = [];
                break;
        }
    }
}


function trouverMeilleurPanier($typePanier, $prixCible, $legumes, $stockInitialTotal) {
    $tolerance = $GLOBALS['TYPES_PANIERS'][$typePanier]['tolerance'];
    $meilleureComposition = null;
    $meilleurPoids = 0;
    $profit = 0.8;
    
    // Calculer le coût cible (95% du prix de vente)
    $coutCible = $prixCible * $profit;
    
    // Trier les légumes par stock à écouler en priorité
    uasort($legumes, function($a, $b) {
        return ($b['stock'] * $b['poids_unite']) <=> ($a['stock'] * $a['poids_unite']);
    });

    // Commencer avec les légumes ayant le plus de stock
    foreach ($legumes as $nom => $legume) {
        if ($legume['stock'] <= 0) continue;
        
        // Essayer différentes quantités du légume de base
        for ($qte = 1; $qte <= min($legume['stock'], 10); $qte++) {
            $cout = $qte * $legume['poids_unite'] * $legume['prix_kg'];
            if ($cout > $coutCible + $tolerance) break;
            
            $composition = [$nom => $qte];
            $coutTotal = $cout;
            
            // Ajouter d'autres légumes si possible
            foreach ($legumes as $nom2 => $legume2) {
                if ($nom2 === $nom || $legume2['stock'] <= 0) continue;
                
                for ($qte2 = 1; $qte2 <= min($legume2['stock'], 5); $qte2++) {
                    $nouveauCout = $coutTotal + ($qte2 * $legume2['poids_unite'] * $legume2['prix_kg']);
                    if ($nouveauCout > $coutCible + $tolerance) break;
                    
                    $composition[$nom2] = $qte2;
                    $coutTotal = $nouveauCout;
                    
                    // Si on est dans la fourchette de prix acceptable (≤ 95% du prix de vente ± tolérance)
                    if ($coutTotal >= $coutCible - $tolerance && $coutTotal <= $coutCible + $tolerance) {
                        $poidsTotal = array_sum(array_map(function($q, $n) use ($legumes) {
                            return $q * $legumes[$n]['poids_unite'];
                        }, $composition, array_keys($composition)));
                        
                        if ($poidsTotal > $meilleurPoids) {
                            $meilleurPoids = $poidsTotal;
                            $meilleureComposition = $composition;
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

function calculerNombrePaniers($composition, $legumes) {
    $nbPaniers = PHP_INT_MAX;
    foreach ($composition as $legume => $quantite) {
        if ($quantite > 0) {
            $possible = floor($legumes[$legume]['stock'] / $quantite);
            $nbPaniers = min($nbPaniers, $possible);
        }
    }
    return $nbPaniers;
}

function peutCreerPaniersSupplémentaires($legumes, $prixCible, $tolerance) {
    // Calculer le coût cible (95% du prix de vente)
    $profit = 0.8;
    $coutCible = $prixCible * $profit;
    
    // Vérifier si on peut encore faire des paniers avec le stock restant
    foreach ($legumes as $nom1 => $legume1) {
        if ($legume1['stock'] <= 0) continue;
        
        // Tester différentes quantités pour le premier légume
        for ($qte1 = 1; $qte1 <= min($legume1['stock'], 15); $qte1++) {
            $cout1 = $qte1 * $legume1['poids_unite'] * $legume1['prix_kg'];
            if ($cout1 > $coutCible + $tolerance) break;
            
            // Si on peut faire au moins 100 paniers, on teste avec un second légume
            foreach ($legumes as $nom2 => $legume2) {
                if ($nom2 === $nom1 || $legume2['stock'] <= 0) continue;
                
                for ($qte2 = 1; $qte2 <= min($legume2['stock'], 15); $qte2++) {
                    $coutTotal = $cout1 + ($qte2 * $legume2['poids_unite'] * $legume2['prix_kg']);
                    
                    if ($coutTotal >= $coutCible - $tolerance && $coutTotal <= $coutCible + $tolerance) {
                        // Calculer combien de paniers on peut faire
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

function optimiserDistribution($legumes) {
    $resultats = [];
    $stockRestant = $legumes;
    $numeroFormat = 1;
    
    // Calculer le stock initial total
    $stockInitialTotal = array_sum(array_map(function($leg) {
        return $leg['stock'] * $leg['poids_unite'];
    }, $legumes));
    
    while (true) {
        $stockRestantTotal = array_sum(array_map(function($leg) {
            return $leg['stock'] * $leg['poids_unite'];
        }, $stockRestant));
        
        if ($stockRestantTotal <= ($stockInitialTotal * 0.0001)) {
            break;
        }
        
        // Phase 1 : Essayer les paniers standards
        $meilleurType = null;
        $meilleurPanier = null;
        $meilleureUtilisation = 0;
        
        foreach ($GLOBALS['TYPES_PANIERS'] as $type => $config) {
            $panier = trouverMeilleurPanier($type, $config['prix'], $stockRestant, $stockInitialTotal);
            if ($panier) {
                $nbPaniers = calculerNombrePaniers($panier['composition'], $stockRestant);
                if ($nbPaniers >= 100) {  // Minimum 100 paniers
                    $utilisation = ($panier['poids'] * $nbPaniers) / $stockInitialTotal * 100;
                    if ($utilisation > $meilleureUtilisation) {
                        $meilleurPanier = $panier;
                        $meilleurType = $type;
                        $meilleureUtilisation = $utilisation;
                    }
                }
            }
        }
        
        // Si aucun panier standard trouvé, essayer des paniers optimisés pour les restes
        if (!$meilleurPanier) {
            foreach ($GLOBALS['TYPES_PANIERS'] as $type => $config) {
                $panierOptimise = peutCreerPaniersSupplémentaires($stockRestant, $config['prix'], $config['tolerance']);
                if ($panierOptimise) {
                    $meilleurPanier = $panierOptimise;
                    $meilleurType = $type;
                    break;
                }
            }
            if (!$meilleurPanier) break;
        }
        
        // Vérifier encore une fois le nombre minimum de paniers
        $nbPaniers = calculerNombrePaniers($meilleurPanier['composition'], $stockRestant);
        if ($nbPaniers < 100) break;  // Arrêter si on ne peut pas faire au moins 100 paniers
        
        // Ajouter aux résultats
        $config = $GLOBALS['TYPES_PANIERS'][$meilleurType];
        
        $typeComplet = $meilleurType . '_' . $numeroFormat;
        $resultats[$typeComplet] = [
            'composition' => $meilleurPanier['composition'],
            'nbPaniers' => $nbPaniers,
            'prixUnitaire' => $config['prix'],
            'coutUnitaire' => $meilleurPanier['cout'],
            'poidsUnitaire' => $meilleurPanier['poids'],
            'margeUnitaire' => $config['prix'] - $meilleurPanier['cout']
        ];
        
        // Mettre à jour le stock
        foreach ($meilleurPanier['composition'] as $legume => $quantite) {
            $stockRestant[$legume]['stock'] -= $quantite * $nbPaniers;
        }
        
        $numeroFormat++;
    }
    
    return ['paniers' => $resultats, 'stockRestant' => $stockRestant];
}

$resultats = !empty($_SESSION['legumes']) ? optimiserDistribution($_SESSION['legumes']) : null;
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Optimisation des Paniers de Légumes</title>
    <style>
        /* Styles similaires... */
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #3498db;
            --success-color: #27ae60;
            --warning-color: #f1c40f;
            --danger-color: #e74c3c;
            --background-color: #ecf0f1;
            --card-background: #ffffff;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            background-color: var(--background-color);
            color: var(--primary-color);
            padding: 2rem;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .card {
            background: var(--card-background);
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }

        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            background-color: var(--secondary-color);
            color: white;
            margin: 5px;
        }

        .btn-danger {
            background-color: var(--danger-color);
        }

        .stock-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }

        .stock-table th,
        .stock-table td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        .stock-table th {
            background-color: var(--secondary-color);
            color: white;
        }

        .popup {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }

        .popup-content {
            background: white;
            padding: 20px;
            border-radius: 8px;
            width: 90%;
            max-width: 500px;
            margin: 50px auto;
        }

        .dashboard {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }

        .composition-list {
            list-style: none;
            padding: 0;
        }

        .composition-list li {
            padding: 5px 0;
            border-bottom: 1px solid #eee;
        }

        .marge-positive { color: var(--success-color); }
        .marge-negative { color: var(--danger-color); }
    </style>
</head>
<body>
    <div class="container">
        <h1>Optimisation des Paniers de Légumes</h1>

        <div class="actions">
            <button onclick="ouvrirPopup()" class="btn">Ajouter un légume</button>
            <form method="POST" style="display: inline;">
                <input type="hidden" name="action" value="reset">
                <button type="submit" class="btn btn-danger">Réinitialiser</button>
            </form>
        </div>

        <!-- Popup d'ajout de légume -->
        <div id="popupLegume" class="popup">
            <div class="popup-content">
                <h2>Ajouter un nouveau légume</h2>
                <form method="POST">
                    <input type="hidden" name="action" value="ajouter">
                    
                    <div class="form-group">
                        <label for="nom">Nom du légume :</label>
                        <input type="text" id="nom" name="nom" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="stock">Nombre d'unités disponibles :</label>
                        <input type="number" id="stock" name="stock" min="1" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="poids_unite">Poids par unité (kg) :</label>
                        <input type="number" id="poids_unite" name="poids_unite" step="0.001" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="prix_kg">Prix au kg (€) :</label>
                        <input type="number" id="prix_kg" name="prix_kg" step="0.01" required>
                    </div>
                    
                    <button type="submit" class="btn">Ajouter</button>
                    <button type="button" onclick="fermerPopup()" class="btn btn-danger">Annuler</button>
                </form>
            </div>
        </div>

        <!-- Liste des légumes -->
        <div class="card">
    <h2>Légumes disponibles</h2>
    <table class="stock-table">
        <thead>
            <tr>
                <th>Légume</th>
                <th>Stock (unités)</th>
                <th>Poids/unité (kg)</th>
                <th>Prix/kg (€)</th>
                <th>Stock total (kg)</th>
                <th>Valeur totale (€)</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($_SESSION['legumes'] as $nom => $legume): ?>
                <tr>
                    <td><?= htmlspecialchars(ucfirst($nom)) ?></td>
                    <td><?= $legume['stock'] ?></td>
                    <td><?= number_format($legume['poids_unite'], 3) ?></td>
                    <td><?= number_format($legume['prix_kg'], 2) ?></td>
                    <td><?= number_format($legume['stock'] * $legume['poids_unite'], 2) ?></td>
                    <td><?= number_format($legume['stock'] * $legume['poids_unite'] * $legume['prix_kg'], 2) ?></td>
                    <td>
                        <form method="POST" style="display:inline">
                            <input type="hidden" name="action" value="supprimer">
                            <input type="hidden" name="nom" value="<?= htmlspecialchars($nom) ?>">
                            <button type="submit" class="btn btn-danger" style="padding: 2px 8px; margin: 0;">×</button>
                        </form>
                    </td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</div>

        <!-- Résultats de l'optimisation -->
        <?php if ($resultats && !empty($resultats['paniers'])): ?>
            <div class="dashboard">
                <?php foreach ($resultats['paniers'] as $type => $details): ?>
                    <div class="card">
                        <h2>Panier <?= ucfirst($type) ?></h2>
                        <div class="stats">
                            <div class="stat-card">
                                <h3><?= $details['nbPaniers'] ?></h3>
                                <p>Paniers possibles</p>
                            </div>
                            <div class="stat-card">
                                <h3><?= number_format($details['prixUnitaire'], 2) ?>€</h3>
                                <p>Prix de vente</p>
                            </div>
                        </div>
                        
                        <h3>Composition par panier :</h3>
                        <ul class="composition-list">
                            <?php foreach ($details['composition'] as $legume => $quantite): ?>
                                <li>
                                    <?= ucfirst($legume) ?>: <?= $quantite ?> unité(s)
                                    (<?= number_format($quantite * $_SESSION['legumes'][$legume]['poids_unite'], 3) ?> kg
                                    à <?= number_format($_SESSION['legumes'][$legume]['prix_kg'], 2) ?>€/kg)
                                </li>
                            <?php endforeach; ?>
                        </ul>
                        
                        <div style="margin-top: 1rem;">
                            <p>Poids total : <?= number_format($details['poidsUnitaire'], 3) ?> kg</p>
                            <p>Coût par panier : <?= number_format($details['coutUnitaire'], 2) ?>€</p>
                            <p>Marge par panier : 
                                <span class="<?= $details['margeUnitaire'] >= 0 ? 'marge-positive' : 'marge-negative' ?>">
                                    <?= number_format($details['margeUnitaire'], 2) ?>€
                                </span>
                            </p>
                            <p>Marge totale : 
                                <span class="<?= $details['margeUnitaire'] >= 0 ? 'marge-positive' : 'marge-negative' ?>">
                                    <?= number_format($details['margeUnitaire'] * $details['nbPaniers'], 2) ?>€
                                </span>
                            </p>
                        </div>
                    </div>
                <?php endforeach; ?>

                <!-- Stock restant -->
                <div class="card">
                    <h2>Stock Restant</h2>
                    <table class="stock-table">
                        <thead>
                            <tr>
                                <th>Légume</th>
                                <th>Unités restantes</th>
                                <th>Poids total (kg)</th>
                                <th>Valeur (€)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($resultats['stockRestant'] as $legume => $details): ?>
                                <?php if ($details['stock'] > 0): ?>
                                    <tr>
                                        <td><?= ucfirst($legume) ?></td>
                                        <td><?= $details['stock'] ?></td>
                                        <td><?= number_format($details['stock'] * $details['poids_unite'], 3) ?></td>
                                        <td><?= number_format($details['stock'] * $details['poids_unite'] * $details['prix_kg'], 2) ?></td>
                                    </tr>
                                <?php endif; ?>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        <?php endif; ?>
    </div>

    <script>
        function ouvrirPopup() {
            document.getElementById('popupLegume').style.display = 'block';
        }

        function fermerPopup() {
            document.getElementById('popupLegume').style.display = 'none';
        }

        // Fermer la popup si on clique en dehors
        window.onclick = function(event) {
            var popup = document.getElementById('popupLegume');
            if (event.target == popup) {
                popup.style.display = 'none';
            }
        }
    </script>
</body>
</html>