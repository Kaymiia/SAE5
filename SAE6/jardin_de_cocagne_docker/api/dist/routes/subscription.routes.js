"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const database_1 = __importDefault(require("../config/database")); // Connexion PostgreSQL
const router = (0, express_1.Router)();
// 🚀 Récupérer tous les abonnements
router.get('/', async (req, res) => {
    try {
        const result = await database_1.default.query(`
      SELECT 
        us.id, 
        us.user_id, 
        us.basket_id, 
        us.status, 
        us.created_at, 
        us.updated_at,
        b.name as basket_name, 
        b.price, 
        b.weight,
        b.image_url,
        dp.id as delivery_point_id,
        dp.name as delivery_point_name,
        dr.name as route_name,
        dr.day_of_week as frequency
      FROM user_subscriptions us
      JOIN baskets b ON us.basket_id = b.id
      LEFT JOIN delivery_points dp ON us.delivery_point_id = dp.id
      LEFT JOIN delivery_routes dr ON dp.route_id = dr.id
    `);
        res.json(result.rows);
    }
    catch (error) {
        console.error('Erreur lors de la récupération des abonnements:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Récupérer les abonnements d'un utilisateur
router.get('/user/:userId', async (req, res) => {
    const userId = parseInt(req.params.userId);
    try {
        const result = await database_1.default.query(`
      SELECT 
        us.id, 
        us.user_id, 
        us.basket_id, 
        us.status, 
        us.created_at, 
        us.updated_at,
        b.name as basket_name, 
        b.price, 
        b.weight,
        b.image_url,
        dp.id as delivery_point_id,
        dp.name as delivery_point_name,
        dr.name as route_name,
        dr.day_of_week as frequency
      FROM user_subscriptions us
      JOIN baskets b ON us.basket_id = b.id
      LEFT JOIN delivery_points dp ON us.delivery_point_id = dp.id
      LEFT JOIN delivery_routes dr ON dp.route_id = dr.id
      WHERE us.user_id = $1
    `, [userId]);
        res.json(result.rows);
    }
    catch (error) {
        console.error('Erreur lors de la récupération des abonnements de l\'utilisateur:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Récupérer un abonnement par ID
router.get('/:id', async (req, res) => {
    const id = parseInt(req.params.id);
    try {
        const result = await database_1.default.query(`
      SELECT 
        us.id, 
        us.user_id, 
        us.basket_id, 
        us.status, 
        us.created_at, 
        us.updated_at,
        b.name as basket_name, 
        b.price, 
        b.weight,
        b.image_url,
        dp.id as delivery_point_id,
        dp.name as delivery_point_name,
        dr.name as route_name,
        dr.day_of_week as frequency
      FROM user_subscriptions us
      JOIN baskets b ON us.basket_id = b.id
      LEFT JOIN delivery_points dp ON us.delivery_point_id = dp.id
      LEFT JOIN delivery_routes dr ON dp.route_id = dr.id
      WHERE us.id = $1
    `, [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Abonnement non trouvé' });
        }
        res.json(result.rows[0]);
    }
    catch (error) {
        console.error('Erreur lors de la récupération de l\'abonnement:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Route de test pour la création d'abonnement
router.post('/', async (req, res) => {
    try {
        console.log('Création d\'abonnement - Données reçues:', JSON.stringify(req.body));
        const { user_id, basket_id, delivery_point_id, status } = req.body;
        // Validation des données d'entrée
        if (!user_id || !basket_id || !delivery_point_id) {
            return res.status(400).json({
                message: 'ID utilisateur, ID panier et ID point de livraison sont requis'
            });
        }
        // Conversion des ID en nombres
        const userIdNum = Number(user_id);
        const basketIdNum = Number(basket_id);
        const deliveryPointIdNum = Number(delivery_point_id);
        // Vérification des ID
        if (isNaN(userIdNum) || isNaN(basketIdNum) || isNaN(deliveryPointIdNum)) {
            return res.status(400).json({
                message: 'Les ID doivent être des nombres valides'
            });
        }
        // Vérifier l'existence de l'utilisateur
        const userCheck = await database_1.default.query('SELECT * FROM users WHERE id = $1', [userIdNum]);
        if (userCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Utilisateur non trouvé' });
        }
        // Vérifier l'existence du panier
        const basketCheck = await database_1.default.query('SELECT * FROM baskets WHERE id = $1', [basketIdNum]);
        if (basketCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Panier non trouvé' });
        }
        // Vérifier l'existence du point de livraison
        const deliveryPointCheck = await database_1.default.query('SELECT * FROM delivery_points WHERE id = $1', [deliveryPointIdNum]);
        if (deliveryPointCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Point de livraison non trouvé' });
        }
        // Vérifier la contrainte d'unicité
        const existingSubscription = await database_1.default.query('SELECT * FROM user_subscriptions WHERE user_id = $1 AND basket_id = $2', [userIdNum, basketIdNum]);
        if (existingSubscription.rows.length > 0) {
            return res.status(409).json({
                message: 'Un abonnement existe déjà pour cet utilisateur et ce panier',
                existingSubscription: existingSubscription.rows[0]
            });
        }
        // Créer l'abonnement
        const result = await database_1.default.query('INSERT INTO user_subscriptions (user_id, basket_id, delivery_point_id, status) VALUES ($1, $2, $3, $4) RETURNING *', [userIdNum, basketIdNum, deliveryPointIdNum, status || 'active']);
        // Récupérer les détails complets de l'abonnement
        const subscriptionDetails = await database_1.default.query(`
        SELECT 
          us.id, 
          us.user_id, 
          us.basket_id, 
          us.status, 
          us.created_at, 
          us.updated_at,
          b.name as basket_name, 
          b.price, 
          b.weight,
          b.image_url,
          dp.id as delivery_point_id,
          dp.name as delivery_point_name,
          dr.name as route_name,
          dr.day_of_week as frequency
        FROM user_subscriptions us
        JOIN baskets b ON us.basket_id = b.id
        LEFT JOIN delivery_points dp ON us.delivery_point_id = dp.id
        LEFT JOIN delivery_routes dr ON dp.route_id = dr.id
        WHERE us.id = $1
      `, [result.rows[0].id]);
        res.status(201).json(subscriptionDetails.rows[0]);
    }
    catch (error) {
        console.error('Erreur lors de la création de l\'abonnement:', error);
        res.status(500).json({
            message: 'Erreur serveur',
            error: error instanceof Error ? error.message : String(error)
        });
    }
});
// 🚀 Mettre à jour le statut d'un abonnement
router.patch('/:id/status', async (req, res) => {
    const id = parseInt(req.params.id);
    const { status } = req.body;
    if (!status) {
        return res.status(400).json({ message: 'Le statut est requis' });
    }
    if (!['active', 'suspended', 'cancelled'].includes(status)) {
        return res.status(400).json({ message: 'Statut invalide. Utilisez "active", "suspended" ou "cancelled"' });
    }
    try {
        const result = await database_1.default.query('UPDATE user_subscriptions SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *', [status, id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Abonnement non trouvé' });
        }
        // Récupérer les détails complets de l'abonnement mis à jour
        const subscription = await database_1.default.query(`
      SELECT 
        us.id, 
        us.user_id, 
        us.basket_id, 
        us.status, 
        us.created_at, 
        us.updated_at,
        b.name as basket_name, 
        b.price, 
        b.weight,
        b.image_url,
        dp.id as delivery_point_id,
        dp.name as delivery_point_name,
        dr.name as route_name,
        dr.day_of_week as frequency
      FROM user_subscriptions us
      JOIN baskets b ON us.basket_id = b.id
      LEFT JOIN delivery_points dp ON us.delivery_point_id = dp.id
      LEFT JOIN delivery_routes dr ON dp.route_id = dr.id
      WHERE us.id = $1
    `, [id]);
        res.json(subscription.rows[0]);
    }
    catch (error) {
        console.error('Erreur lors de la mise à jour du statut de l\'abonnement:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Mettre à jour un abonnement
router.put('/:id', async (req, res) => {
    const id = parseInt(req.params.id);
    const { user_id, basket_id, delivery_point_id, status } = req.body;
    try {
        // Vérifier que l'abonnement existe
        const subscription = await database_1.default.query('SELECT * FROM user_subscriptions WHERE id = $1', [id]);
        if (subscription.rows.length === 0) {
            return res.status(404).json({ message: 'Abonnement non trouvé' });
        }
        // Mettre à jour l'abonnement
        const result = await database_1.default.query('UPDATE user_subscriptions SET user_id = $1, basket_id = $2, delivery_point_id = $3, status = $4, updated_at = NOW() WHERE id = $5 RETURNING *', [user_id, basket_id, delivery_point_id, status, id]);
        // Récupérer les détails complets de l'abonnement mis à jour
        const updatedSubscription = await database_1.default.query(`
      SELECT 
        us.id, 
        us.user_id, 
        us.basket_id, 
        us.status, 
        us.created_at, 
        us.updated_at,
        b.name as basket_name, 
        b.price, 
        b.weight,
        b.image_url,
        dp.id as delivery_point_id,
        dp.name as delivery_point_name,
        dr.name as route_name,
        dr.day_of_week as frequency
      FROM user_subscriptions us
      JOIN baskets b ON us.basket_id = b.id
      LEFT JOIN delivery_points dp ON us.delivery_point_id = dp.id
      LEFT JOIN delivery_routes dr ON dp.route_id = dr.id
      WHERE us.id = $1
    `, [id]);
        res.json(updatedSubscription.rows[0]);
    }
    catch (error) {
        console.error('Erreur lors de la mise à jour de l\'abonnement:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Supprimer un abonnement
router.delete('/:id', async (req, res) => {
    const id = parseInt(req.params.id);
    try {
        // Récupérer l'abonnement avant de le supprimer
        const subscription = await database_1.default.query('SELECT * FROM user_subscriptions WHERE id = $1', [id]);
        if (subscription.rows.length === 0) {
            return res.status(404).json({ message: 'Abonnement non trouvé' });
        }
        // Supprimer l'abonnement
        await database_1.default.query('DELETE FROM user_subscriptions WHERE id = $1', [id]);
        res.json({ message: `Abonnement ${id} supprimé`, subscription: subscription.rows[0] });
    }
    catch (error) {
        console.error('Erreur lors de la suppression de l\'abonnement:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
exports.default = router;
