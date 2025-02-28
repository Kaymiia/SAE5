"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const database_1 = __importDefault(require("../config/database"));
const router = (0, express_1.Router)();
// Récupérer tous les points de livraison
router.get('/', async (req, res) => {
    try {
        const result = await database_1.default.query(`
      SELECT 
        dp.*,
        dr.day_of_week,
        dr.name as route_name
      FROM delivery_points dp
      JOIN delivery_routes dr ON dp.route_id = dr.id
      ORDER BY dr.day_of_week, dp.sequence_order
    `);
        res.json(result.rows);
    }
    catch (error) {
        console.error('Erreur lors de la récupération des points de livraison:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// Récupérer les points de livraison pour un jour spécifique
router.get('/day/:day', async (req, res) => {
    const day = req.params.day;
    try {
        const result = await database_1.default.query(`
      SELECT 
        dp.*,
        dr.day_of_week,
        dr.name as route_name
      FROM delivery_points dp
      JOIN delivery_routes dr ON dp.route_id = dr.id
      WHERE dr.day_of_week = $1
      ORDER BY dp.sequence_order
    `, [day]);
        res.json(result.rows);
    }
    catch (error) {
        console.error('Erreur lors de la récupération des points de livraison:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// Récupérer tous les jours de livraison disponibles
router.get('/days', async (req, res) => {
    try {
        const result = await database_1.default.query(`
      SELECT DISTINCT day_of_week
      FROM delivery_routes
      WHERE is_active = true
      ORDER BY 
        CASE
          WHEN day_of_week = 'Lundi' THEN 1
          WHEN day_of_week = 'Mardi' THEN 2
          WHEN day_of_week = 'Mercredi' THEN 3
          WHEN day_of_week = 'Jeudi' THEN 4
          WHEN day_of_week = 'Vendredi' THEN 5
          WHEN day_of_week = 'Samedi' THEN 6
          WHEN day_of_week = 'Dimanche' THEN 7
        END
    `);
        const days = result.rows.map(row => row.day_of_week);
        res.json(days);
    }
    catch (error) {
        console.error('Erreur lors de la récupération des jours de livraison:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// Récupérer un point de livraison par ID
router.get('/:id', async (req, res) => {
    const id = parseInt(req.params.id);
    try {
        const result = await database_1.default.query(`
      SELECT 
        dp.*,
        dr.day_of_week,
        dr.name as route_name
      FROM delivery_points dp
      JOIN delivery_routes dr ON dp.route_id = dr.id
      WHERE dp.id = $1
    `, [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Point de livraison non trouvé' });
        }
        res.json(result.rows[0]);
    }
    catch (error) {
        console.error('Erreur lors de la récupération du point de livraison:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
router.patch('/:id/status', async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;
    // Valider le statut
    const validStatuses = ['non livré', 'en cours', 'prêt'];
    if (!validStatuses.includes(status)) {
        return res.status(400).json({ message: 'Statut invalide' });
    }
    try {
        const result = await database_1.default.query('UPDATE delivery_points SET delivery_status = $1, updated_at = NOW() WHERE id = $2 RETURNING *', [status, id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Point de livraison non trouvé' });
        }
        res.json(result.rows[0]);
    }
    catch (error) {
        console.error('Erreur mise à jour statut:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// Réinitialiser les statuts avant chaque jour de livraison
router.post('/reset-status', async (req, res) => {
    const { day_of_week } = req.body;
    try {
        const result = await database_1.default.query(`
        UPDATE delivery_points dp
        SET delivery_status = 'non livré'
        FROM delivery_routes dr
        WHERE dp.route_id = dr.id AND dr.day_of_week = $1
      `, [day_of_week]);
        res.json({ message: 'Statuts réinitialisés', updatedCount: result.rowCount });
    }
    catch (error) {
        console.error('Erreur réinitialisation statuts:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
exports.default = router;
