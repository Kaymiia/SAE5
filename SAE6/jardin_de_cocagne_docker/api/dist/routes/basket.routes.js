"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const database_1 = __importDefault(require("../config/database")); // Connexion PostgreSQL
const router = (0, express_1.Router)();
// 🚀 Récupérer tous les paniers
router.get('/', async (req, res) => {
    try {
        const result = await database_1.default.query('SELECT * FROM baskets');
        res.json(result.rows);
    }
    catch (error) {
        console.error('Erreur lors de la récupération des paniers:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Récupérer un panier par ID avec ses produits
router.get('/:id', async (req, res) => {
    const id = parseInt(req.params.id);
    try {
        const basket = await database_1.default.query('SELECT * FROM baskets WHERE id = $1', [id]);
        if (basket.rows.length === 0) {
            return res.status(404).json({ message: 'Panier non trouvé' });
        }
        // Récupérer les produits du panier
        const products = await database_1.default.query('SELECT * FROM basket_products WHERE basket_id = $1', [id]);
        basket.rows[0].products = products.rows;
        res.json(basket.rows[0]);
    }
    catch (error) {
        console.error('Erreur lors de la récupération du panier:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Créer un panier
router.post('/', async (req, res) => {
    const { name, description, price, weight, image_url } = req.body;
    if (!name || !price) {
        return res.status(400).json({ message: 'Nom et prix sont requis' });
    }
    try {
        const result = await database_1.default.query('INSERT INTO baskets (name, description, price, weight, image_url) VALUES ($1, $2, $3, $4, $5) RETURNING *', [name, description, price, weight, image_url]);
        res.status(201).json(result.rows[0]);
    }
    catch (error) {
        console.error('Erreur lors de la création du panier:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Modifier un panier
router.put('/:id', async (req, res) => {
    const id = parseInt(req.params.id);
    const { name, description, price, weight, image_url } = req.body;
    try {
        const result = await database_1.default.query('UPDATE baskets SET name = $1, description = $2, price = $3, weight = $4, image_url = $5 WHERE id = $6 RETURNING *', [name, description, price, weight, image_url, id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Panier non trouvé' });
        }
        res.json(result.rows[0]);
    }
    catch (error) {
        console.error('Erreur lors de la mise à jour du panier:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Supprimer un panier
router.delete('/:id', async (req, res) => {
    const id = parseInt(req.params.id);
    try {
        // Supprimer les produits du panier
        await database_1.default.query('DELETE FROM basket_products WHERE basket_id = $1', [id]);
        // Supprimer le panier
        const result = await database_1.default.query('DELETE FROM baskets WHERE id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Panier non trouvé' });
        }
        res.json({ message: `Panier ${id} supprimé`, basket: result.rows[0] });
    }
    catch (error) {
        console.error('Erreur lors de la suppression du panier:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Ajouter un produit à un panier
router.post('/:basketId/products', async (req, res) => {
    const basketId = parseInt(req.params.basketId);
    const { product_id, quantity } = req.body;
    if (!product_id || quantity <= 0) {
        return res.status(400).json({ message: 'ID de produit et quantité positive requis' });
    }
    try {
        const result = await database_1.default.query('INSERT INTO basket_products (basket_id, product_id, quantity) VALUES ($1, $2, $3) RETURNING *', [basketId, product_id, quantity]);
        res.status(201).json(result.rows[0]);
    }
    catch (error) {
        console.error('Erreur lors de l\'ajout du produit au panier:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Récupérer les produits d'un panier
router.get('/:basketId/products', async (req, res) => {
    const basketId = parseInt(req.params.basketId);
    try {
        const result = await database_1.default.query('SELECT * FROM basket_products WHERE basket_id = $1', [basketId]);
        res.json(result.rows);
    }
    catch (error) {
        console.error('Erreur lors de la récupération des produits du panier:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Mettre à jour un produit dans un panier
router.put('/:basketId/products/:productId', async (req, res) => {
    const basketId = parseInt(req.params.basketId);
    const productId = parseInt(req.params.productId);
    const { quantity } = req.body;
    if (quantity !== undefined && quantity <= 0) {
        return res.status(400).json({ message: 'La quantité doit être positive' });
    }
    try {
        const result = await database_1.default.query('UPDATE basket_products SET quantity = $1 WHERE basket_id = $2 AND product_id = $3 RETURNING *', [quantity, basketId, productId]);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Produit non trouvé dans ce panier' });
        }
        res.json(result.rows[0]);
    }
    catch (error) {
        console.error('Erreur lors de la mise à jour du produit du panier:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Supprimer un produit d'un panier
router.delete('/:basketId/products/:productId', async (req, res) => {
    const basketId = parseInt(req.params.basketId);
    const productId = parseInt(req.params.productId);
    try {
        const result = await database_1.default.query('DELETE FROM basket_products WHERE basket_id = $1 AND product_id = $2 RETURNING *', [basketId, productId]);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Produit non trouvé dans ce panier' });
        }
        res.json({ message: 'Produit retiré du panier', product: result.rows[0] });
    }
    catch (error) {
        console.error('Erreur lors de la suppression du produit du panier:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
exports.default = router;
