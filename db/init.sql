-- Table pour stocker les trajets
CREATE TABLE IF NOT EXISTS routes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    day_of_week VARCHAR(20),
    color VARCHAR(7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table pour stocker les waypoints
CREATE TABLE IF NOT EXISTS waypoints (
    id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT,
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    position_order INT,
    FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE
);

-- Table pour stocker les légumes
CREATE TABLE IF NOT EXISTS legumes (
    nom VARCHAR(100) PRIMARY KEY,
    stock INT NOT NULL,
    poids_unite DECIMAL(10,3) NOT NULL,
    prix_kg DECIMAL(10,2) NOT NULL,
    prix_unite DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Création de la table des paniers
CREATE TABLE IF NOT EXISTS paniers_sauvegardes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    poids_total DECIMAL(10,3) NOT NULL,
    prix_vente DECIMAL(10,2) NOT NULL,
    cout_total DECIMAL(10,2) NOT NULL,
    marge DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Création de la table du contenu des paniers
CREATE TABLE IF NOT EXISTS contenu_paniers_sauvegardes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    panier_id INT NOT NULL,
    legume_nom VARCHAR(100) NOT NULL,
    quantite INT NOT NULL,
    poids_unite DECIMAL(10,3) NOT NULL,
    prix_kg DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (panier_id) REFERENCES paniers_sauvegardes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;