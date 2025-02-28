-- Initialize with some sample data

-- Insert sample products
INSERT INTO products (name, price_per_kg, category, unit, image_url) VALUES
('Carotte', 2.50, 'Légume', 'kg', NULL),
('Pomme de terre', 1.80, 'Légume', 'kg', NULL),
('Poireau', 3.20, 'Légume', 'kg', NULL),
('Tomate', 4.50, 'Fruit', 'kg', NULL),
('Pomme', 3.00, 'Fruit', 'kg', NULL),
('Salade', 1.50, 'Légume', 'pièce', NULL),
('Courgette', 2.80, 'Légume', 'kg', NULL),
('Betterave', 2.90, 'Légume', 'kg', NULL);

-- Insert sample baskets
INSERT INTO baskets (name, price, description, weight, image_url) VALUES
('Panier Petit', 12.00, 'Panier pour 1-2 personnes', '3-4 kg','images/Le_Petit.png'),
('Panier Moyen', 18.00, 'Panier pour 2-3 personnes', '5-6 kg','images/Le_Moyen.png'),
('Panier Très Très Très Grand', 25.00, 'Panier pour 4-5 personnes', '7-9 kg','images/Le_Grand.png');

-- Associate products with baskets
INSERT INTO basket_products (basket_id, product_id, quantity) VALUES
(1, 1, 0.5), -- Petit panier: 500g de carottes
(1, 2, 1.0), -- Petit panier: 1kg de pommes de terre
(1, 6, 1.0), -- Petit panier: 1 salade
(2, 1, 1.0), -- Moyen panier: 1kg de carottes
(2, 2, 1.5), -- Moyen panier: 1.5kg de pommes de terre
(2, 3, 0.5), -- Moyen panier: 500g de poireaux
(2, 6, 1.0), -- Moyen panier: 1 salade
(2, 7, 0.5), -- Moyen panier: 500g de courgettes
(3, 1, 1.5), -- Grand panier: 1.5kg de carottes
(3, 2, 2.0), -- Grand panier: 2kg de pommes de terre
(3, 3, 1.0), -- Grand panier: 1kg de poireaux
(3, 4, 1.0), -- Grand panier: 1kg de tomates
(3, 6, 2.0), -- Grand panier: 2 salades
(3, 7, 1.0), -- Grand panier: 1kg de courgettes
(3, 8, 0.5); -- Grand panier: 500g de betteraves

-- Création des routes de livraison par jour
INSERT INTO delivery_routes (name, day_of_week, is_active) VALUES
('Route Mardi', 'Mardi', true),
('Route Mercredi', 'Mercredi', true),
('Route Jeudi', 'Jeudi', true),
('Route Vendredi', 'Vendredi', true);

-- Points de dépôt pour Mardi
INSERT INTO delivery_points (route_id, name, address, latitude, longitude, sequence_order) VALUES
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mardi'), 'Église Saint Antoine', '12, rue Armand Colle', 48.17436, 6.44962, 1),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mardi'), 'Ligue de l''enseignement', '15, rue Général de Reffye', 48.17216, 6.45184, 2),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mardi'), 'Centre Léo LaGrange', '6, Avenue Salvador Allende', 48.16976, 6.45985, 3),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mardi'), 'APF - Local extérieur', 'Rue de la papeterie à Dinozé', 48.14825, 6.46215, 4),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mardi'), 'Ecodenn''ergie', '36, bis rue de la Plaine', 48.11325, 6.44981, 5),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mardi'), 'Botanic', 'Avenue des Terres St Jean', 48.18025, 6.43981, 6);

-- Points de dépôt pour Mercredi
INSERT INTO delivery_points (route_id, name, address, latitude, longitude, sequence_order) VALUES
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mercredi'), 'Église Saint Antoine', '12, rue Armand Colle', 48.17436, 6.44962, 1),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mercredi'), 'Botanic', 'Avenue des Terres St Jean', 48.18025, 6.43981, 2),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mercredi'), 'Centre Léo Lagrange', '6, Avenue Salvador Allende', 48.16976, 6.45985, 3),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mercredi'), 'Chambre d''Agriculture', '17, Rue André Vitu', 48.17721, 6.44789, 4),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mercredi'), 'Ligue de l''enseignement', '15, rue Général de Reffye', 48.17216, 6.45184, 5),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mercredi'), 'Ecodenn''ergie', '36, bis rue de la Plaine', 48.11325, 6.44981, 6),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mercredi'), 'Pharmacie Robert', '24, rue du Gal de Gaulle', 48.19784, 6.50236, 7),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mercredi'), 'Association AGACI', '26, Rue de la Joncherie', 48.21354, 6.48965, 8),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mercredi'), 'Office du tourisme', '6 Place C. Poncelet', 48.21567, 6.49123, 9),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mercredi'), '7, Rue du Savron', '7, Rue du Savron', 48.15685, 6.52478, 10),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mercredi'), 'Mr et Mme Boulassel', '1, rue Moncey', 48.13526, 6.52986, 11),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Mercredi'), 'Jardins de Cocagne', 'Prairie Claudel', 48.10587, 6.52145, 12);

-- Points de dépôt pour Jeudi
INSERT INTO delivery_points (route_id, name, address, latitude, longitude, sequence_order) VALUES
((SELECT id FROM delivery_routes WHERE day_of_week = 'Jeudi'), 'Madame Pierot', '15, Rue Ste Barbe', 48.23106, 6.26549, 1);

-- Points de dépôt pour Vendredi
INSERT INTO delivery_points (route_id, name, address, latitude, longitude, sequence_order) VALUES
((SELECT id FROM delivery_routes WHERE day_of_week = 'Vendredi'), 'Église Saint Antoine', '12, rue Armand Colle', 48.17436, 6.44962, 1),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Vendredi'), 'Centre Léo Lagrange', '6, Avenue Salvador Allende', 48.16976, 6.45985, 2),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Vendredi'), 'Botanic', 'Avenue des Terres St Jean', 48.18025, 6.43981, 3),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Vendredi'), 'Ligue de l''enseignement', '15, rue Général de Reffye', 48.17216, 6.45184, 4),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Vendredi'), '3ème Rive Café Associatif', '15 rue du Maréchal Lyautey', 48.17356, 6.45982, 5),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Vendredi'), 'Ecodenn''ergie', '36, bis rue de la Plaine', 48.11325, 6.44981, 6),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Vendredi'), 'Point Vert Mafra', 'Zac Barbazan', 48.19589, 6.57982, 7),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Vendredi'), 'Brico Marché', '2 rue de Fraisne', 48.19843, 6.58205, 8),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Vendredi'), 'Pro et Cie', '45, Boulevard d''Alsace', 48.21023, 6.87234, 9),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Vendredi'), 'M. Lecomte François', '24, route du Noirpré', 48.13478, 6.74103, 10),
((SELECT id FROM delivery_routes WHERE day_of_week = 'Vendredi'), 'Jardins de Cocagne', 'Prairie Claudel', 48.10587, 6.52145, 11);

-- Ajouter la colonne city si elle n'existe pas déjà
ALTER TABLE delivery_points ADD COLUMN IF NOT EXISTS city VARCHAR(100);

-- Mettre à jour les villes
UPDATE delivery_points SET city = 'Epinal' WHERE name IN ('Église Saint Antoine', 'Ligue de l''enseignement', 'Centre Léo LaGrange', 'Botanic', 'Chambre d''Agriculture', '3ème Rive Café Associatif');
UPDATE delivery_points SET city = 'Dinozé' WHERE address LIKE '%Dinozé%';
UPDATE delivery_points SET city = 'Golbey' WHERE name = 'Ecodenn''ergie';
UPDATE delivery_points SET city = 'St Nabord' WHERE name = 'Pharmacie Robert';
UPDATE delivery_points SET city = 'Remiremont' WHERE name IN ('Association AGACI', 'Office du tourisme');
UPDATE delivery_points SET city = 'Raon aux Bois' WHERE address = '7, Rue du Savron';
UPDATE delivery_points SET city = 'Docelles' WHERE name = 'Mr et Mme Boulassel';
UPDATE delivery_points SET city = 'Thaon' WHERE name = 'Jardins de Cocagne';
UPDATE delivery_points SET city = 'Charmes' WHERE name = 'Madame Pierot';
UPDATE delivery_points SET city = 'Bruyères' WHERE name IN ('Point Vert Mafra', 'Brico Marché');
UPDATE delivery_points SET city = 'Gérardmer' WHERE name = 'Pro et Cie';
UPDATE delivery_points SET city = 'Le Tholy' WHERE name = 'M. Lecomte François';

ALTER TABLE delivery_points 
ADD COLUMN delivery_status VARCHAR(20) DEFAULT 'non livré' 
CHECK (delivery_status IN ('non livré', 'en cours', 'prêt'));

INSERT INTO users (email, password, first_name, last_name, phone) 
VALUES ('test@example.com', 'motdepasse123', 'Jean', 'Dupont', '0612345678');