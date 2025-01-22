<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Optimisation des Paniers de Légumes</title>
    <style>
        /* CSS styles */
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .btn {
            background-color:rgb(76, 160, 175);
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin: 5px;
        }

        .btn-danger {
            background-color: #f44336;
        }

        .popup {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            z-index: 1000;
        }

        .popup-content {
            background-color: white;
            margin: 15% auto;
            padding: 20px;
            border-radius: 8px;
            width: 80%;
            max-width: 500px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
        }

        .form-group input {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .stock-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        .stock-table th,
        .stock-table td {
            padding: 8px;
            border: 1px solid #ddd;
            text-align: left;
        }

        .stock-table th {
            background-color: #f5f5f5;
        }

        .marge-positive {
            color: green;
        }

        .marge-negative {
            color: red;
        }

        .tabs {
            margin-bottom: 20px;
        }

        .tab {
            padding: 10px 20px;
            border: none;
            background: #ddd;
            cursor: pointer;
        }

        .tab.active {
            background: #1abc9c;
            color: white;
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Gestion des Paniers de Légumes</h1>

        <div class="tabs">
            <button class="tab active" onclick="showTab('optimization')">Optimisation</button>
            <button class="tab" onclick="showTab('saved')">Paniers Sauvegardés</button>
        </div>

        <div id="optimization" class="tab-content active">
            <div class="actions">
                <button onclick="ouvrirPopup()" class="btn">Ajouter un légume</button>
                <button onclick="resetVegetables()" class="btn btn-danger">Réinitialiser</button>
            </div>

            <div id="popupLegume" class="popup">
                <div class="popup-content">
                    <h2>Ajouter un nouveau légume</h2>
                    <form id="vegetableForm" onsubmit="addVegetable(event)">
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

            <div id="vegetables-list" class="card">
                <h2>Légumes disponibles</h2>
                <div id="vegetables-table"></div>
            </div>

            <div id="optimization-results" class="card"></div>
        </div>

        <div id="saved" class="tab-content">
            <div id="saved-baskets" class="card">
                <h2>Paniers Sauvegardés</h2>
                <div id="saved-baskets-list"></div>
            </div>
        </div>
    </div>

    <script>
        const API_URL = '/api/panier.php';

        // Gestion des onglets
        function showTab(tabName) {
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.remove('active');
            });
            document.querySelectorAll('.tab').forEach(tab => {
                tab.classList.remove('active');
            });
            
            document.getElementById(tabName).classList.add('active');
            document.querySelector(`.tab[onclick*="${tabName}"]`).classList.add('active');

            if (tabName === 'saved') {
                loadSavedBaskets();
            }
        }

        // Fonction pour charger les légumes
        async function loadVegetables() {
            try {
                const response = await fetch(API_URL);
                const data = await response.json();
                if (data.status === 'success') {
                    displayVegetables(data.data);
                } else {
                    alert('Erreur lors du chargement des légumes');
                }
            } catch (error) {
                console.error('Erreur:', error);
                alert('Erreur lors du chargement des légumes');
            }
        }

        // Fonction pour afficher les légumes
        function displayVegetables(vegetables) {
            const tableHtml = `
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
                        ${vegetables.map(legume => `
                            <tr>
                                <td>${legume.nom}</td>
                                <td>${legume.stock}</td>
                                <td>${Number(legume.poids_unite).toFixed(3)}</td>
                                <td>${Number(legume.prix_kg).toFixed(2)}</td>
                                <td>${(legume.stock * legume.poids_unite).toFixed(2)}</td>
                                <td>${(legume.stock * legume.poids_unite * legume.prix_kg).toFixed(2)}</td>
                                <td>
                                    <button onclick="deleteVegetable('${legume.nom}')" class="btn btn-danger" style="padding: 2px 8px; margin: 0;">×</button>
                                </td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `;
            document.getElementById('vegetables-table').innerHTML = tableHtml;
        }

        // Fonction pour ajouter un légume
        async function addVegetable(event) {
            event.preventDefault();
            const formData = {
                action: 'add',
                name: document.getElementById('nom').value,
                stock: parseInt(document.getElementById('stock').value),
                unit_weight: parseFloat(document.getElementById('poids_unite').value),
                price_per_kg: parseFloat(document.getElementById('prix_kg').value)
            };

            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(formData)
                });

                const data = await response.json();
                if (data.status === 'success') {
                    fermerPopup();
                    document.getElementById('vegetableForm').reset();
                    loadVegetables();
                    optimizeDistribution();
                } else {
                    alert('Erreur lors de l\'ajout du légume');
                }
            } catch (error) {
                console.error('Erreur:', error);
                alert('Erreur lors de l\'ajout du légume');
            }
        }

        // Fonction pour supprimer un légume
        async function deleteVegetable(name) {
            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'delete',
                        name: name
                    })
                });

                const data = await response.json();
                if (data.status === 'success') {
                    loadVegetables();
                    optimizeDistribution();
                } else {
                    alert('Erreur lors de la suppression du légume');
                }
            } catch (error) {
                console.error('Erreur:', error);
                alert('Erreur lors de la suppression du légume');
            }
        }

        // Fonction pour réinitialiser les légumes
        async function resetVegetables() {
            if (!confirm('Êtes-vous sûr de vouloir supprimer tous les légumes ?')) return;
            
            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'reset'
                    })
                });

                const data = await response.json();
                if (data.status === 'success') {
                    loadVegetables();
                    document.getElementById('optimization-results').innerHTML = '';
                } else {
                    alert('Erreur lors de la réinitialisation');
                }
            } catch (error) {
                console.error('Erreur:', error);
                alert('Erreur lors de la réinitialisation');
            }
        }

        // Fonction pour sauvegarder un panier
        async function saveBasket(type, details) {
            const nom = prompt(`Donnez un nom à ce panier ${type}:`, `Panier ${type} - ${new Date().toLocaleDateString()}`);
            if (!nom) return;

            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'save_basket',
                        nom: nom,
                        type: type,
                        details: details
                    })
                });

                const data = await response.json();
                if (data.status === 'success') {
                    alert(`Le panier "${nom}" a été sauvegardé avec succès !`);
                } else {
                    alert('Erreur lors de la sauvegarde du panier');
                }
            } catch (error) {
                console.error('Erreur:', error);
                alert('Erreur lors de la sauvegarde du panier');
            }
        }

        // Fonction pour charger les paniers sauvegardés
        async function loadSavedBaskets() {
            try {
                const response = await fetch(`${API_URL}?action=get_saved_baskets`);
                const data = await response.json();
                
                if (data.status === 'success') {
                    displaySavedBaskets(data.baskets);
                } else {
                    alert('Erreur lors du chargement des paniers sauvegardés');
                }
            } catch (error) {
                console.error('Erreur:', error);
                alert('Erreur lors du chargement des paniers sauvegardés');
            }
        }

        // Fonction pour afficher les paniers sauvegardés
        function displaySavedBaskets(baskets) {
            let html = '<table class="stock-table">';
            html += `
                <thead>
                    <tr>
                        <th>Nom</th>
                        <th>Type</th>
                        <th>Date de création</th>
                        <th>Poids total (kg)</th>
                        <th>Prix de vente (€)</th>
                        <th>Marge (€)</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    ${baskets.map(panier => `
                        <tr>
                            <td>${panier.nom}</td>
                            <td>${panier.type}</td>
                            <td>${new Date(panier.date_creation).toLocaleDateString()}</td>
                            <td>${Number(panier.poids_total).toFixed(3)}</td>
                            <td>${Number(panier.prix_vente).toFixed(2)}</td>
                            <td class="${panier.marge >= 0 ? 'marge-positive' : 'marge-negative'}">
                                ${Number(panier.marge).toFixed(2)}
                            </td>
                            <td style="white-space: nowrap;">
                                <button onclick="viewBasketDetails(${panier.id})" class="btn">Détails</button>
                                <button onclick="deleteBasket(${panier.id})" class="btn btn-danger">Supprimer</button>
                            </td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>`;
            
            document.getElementById('saved-baskets-list').innerHTML = html;
        }

        // Fonction pour voir les détails d'un panier
        async function viewBasketDetails(id) {
            try {
                const response = await fetch(`${API_URL}?action=get_basket_details&id=${id}`);
                const data = await response.json();
                
                if (data.status === 'success') {
                    const html = `
                        <div class="popup" style="display: block;">
                            <div class="popup-content">
                                <h2>${data.basket.nom}</h2>
                                <p><strong>Type:</strong> ${data.basket.type}</p>
                                <p><strong>Date de création:</strong> ${new Date(data.basket.date_creation).toLocaleDateString()}</p>
                                <p><strong>Poids total:</strong> ${Number(data.basket.poids_total).toFixed(3)} kg</p>
                                <p><strong>Prix de vente:</strong> ${Number(data.basket.prix_vente).toFixed(2)} €</p>
                                <p><strong>Marge:</strong> ${Number(data.basket.marge).toFixed(2)} €</p>
                                
                                <h3>Composition</h3>
                                <table class="stock-table">
                                    <thead>
                                        <tr>
                                            <th>Légume</th>
                                            <th>Quantité</th>
                                            <th>Poids unitaire (kg)</th>
                                            <th>Prix/kg (€)</th>
                                            <th>Total (€)</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${data.contenu.map(item => `
                                            <tr>
                                                <td>${item.legume_nom}</td>
                                                <td>${item.quantite}</td>
                                                <td>${Number(item.poids_unite).toFixed(3)}</td>
                                                <td>${Number(item.prix_kg).toFixed(2)}</td>
                                                <td>${Number(item.quantite * item.poids_unite * item.prix_kg).toFixed(2)}</td>
                                            </tr>
                                        `).join('')}
                                    </tbody>
                                </table>
                                
                                <button onclick="this.closest('.popup').style.display='none'" class="btn">Fermer</button>
                            </div>
                        </div>
                    `;
                    
                    const popupDiv = document.createElement('div');
                    popupDiv.innerHTML = html;
                    document.body.appendChild(popupDiv);
                } else {
                    alert('Erreur lors du chargement des détails du panier');
                }
            } catch (error) {
                console.error('Erreur:', error);
                alert('Erreur lors du chargement des détails du panier');
            }
        }

        // Fonction pour supprimer un panier
        async function deleteBasket(id) {
            if (!confirm('Êtes-vous sûr de vouloir supprimer ce panier ?')) return;

            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'delete_basket',
                        id: id
                    })
                });

                const data = await response.json();
                if (data.status === 'success') {
                    loadSavedBaskets();
                } else {
                    alert('Erreur lors de la suppression du panier');
                }
            } catch (error) {
                console.error('Erreur:', error);
                alert('Erreur lors de la suppression du panier');
            }
        }

        // Fonction pour optimiser la distribution
        async function optimizeDistribution() {
            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'optimize'
                    })
                });

                const data = await response.json();
                if (data.status === 'success') {
                    displayOptimizationResults(data);
                } else {
                    console.error('Erreur d\'optimisation:', data.message);
                }
            } catch (error) {
                console.error('Erreur:', error);
            }
        }

        // Fonction pour afficher les résultats d'optimisation
        function displayOptimizationResults(data) {
            if (!data.paniers) return;

            let html = '';
            
            // Affichage des paniers
            for (const [type, details] of Object.entries(data.paniers)) {
                html += `
                    <div class="card">
                        <h2>Panier ${type}</h2>
                        <div class="stats">
                            <div class="stat-card">
                                <h3>${details.nbPaniers}</h3>
                                <p>Paniers possibles</p>
                            </div>
                            <div class="stat-card">
                                <h3>${details.prixUnitaire.toFixed(2)}€</h3>
                                <p>Prix de vente</p>
                            </div>
                        </div>
                        
                        <h3>Composition par panier :</h3>
                        <ul class="composition-list">
                            ${Object.entries(details.composition).map(([legume, quantite]) => `
                                <li>
                                    ${legume}: ${quantite} unité(s)
                                </li>
                            `).join('')}
                        </ul>
                        
                        <div style="margin-top: 1rem;">
                            <button onclick='saveBasket("${type}", ${JSON.stringify(details).replace(/'/g, "\\'")})' class="btn">
                                Sauvegarder ce panier
                            </button>
                            <p>Poids total : ${details.poidsUnitaire.toFixed(3)} kg</p>
                            <p>Coût par panier : ${details.coutUnitaire.toFixed(2)}€</p>
                            <p>Marge par panier : 
                                <span class="${details.margeUnitaire >= 0 ? 'marge-positive' : 'marge-negative'}">
                                    ${details.margeUnitaire.toFixed(2)}€
                                </span>
                            </p>
                            <p>Marge totale : 
                                <span class="${details.margeUnitaire >= 0 ? 'marge-positive' : 'marge-negative'}">
                                    ${(details.margeUnitaire * details.nbPaniers).toFixed(2)}€
                                </span>
                            </p>
                        </div>
                    </div>
                `;
            }

            // Ajout de la section des stocks restants
            if (data.stockRestant) {
                html += `
                    <div class="card">
                        <h2>Stocks restants estimés après création des paniers</h2>
                        <table class="stock-table">
                            <thead>
                                <tr>
                                    <th>Légume</th>
                                    <th>Unités restantes</th>
                                    <th>Poids total (kg)</th>
                                    <th>Valeur restante (€)</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${Object.entries(data.stockRestant)
                                    .filter(([_, details]) => details.stock > 0)
                                    .map(([legume, details]) => `
                                        <tr>
                                            <td>${legume}</td>
                                            <td>${details.stock}</td>
                                            <td>${(details.stock * details.poids_unite).toFixed(3)}</td>
                                            <td>${(details.stock * details.poids_unite * details.prix_kg).toFixed(2)}</td>
                                        </tr>
                                    `).join('')}
                            </tbody>
                        </table>
                    </div>
                `;
            }

            document.getElementById('optimization-results').innerHTML = html;
        }

        function ouvrirPopup() {
            document.getElementById('popupLegume').style.display = 'block';
        }

        function fermerPopup() {
            document.getElementById('popupLegume').style.display = 'none';
        }

        window.onclick = function(event) {
            var popup = document.getElementById('popupLegume');
            if (event.target == popup) {
                popup.style.display = 'none';
            }
        }

        // Charger les données initiales
        document.addEventListener('DOMContentLoaded', () => {
            loadVegetables();
            optimizeDistribution();
        });
    </script>
</body>
</html>