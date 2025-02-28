"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const database_1 = __importDefault(require("../config/database")); // Connexion PostgreSQL
const router = (0, express_1.Router)();
// 🚀 Récupérer toutes les routes de livraison
router.get('/routes', async (req, res) => {
    try {
        const result = await database_1.default.query('SELECT * FROM delivery_routes');
        res.json(result.rows);
    }
    catch (error) {
        console.error('Erreur lors de la récupération des routes de livraison:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Récupérer une route de livraison par ID
router.get('/routes/:id', async (req, res) => {
    const id = parseInt(req.params.id);
    try {
        const route = await database_1.default.query('SELECT * FROM delivery_routes WHERE id = $1', [id]);
        if (route.rows.length === 0) {
            return res.status(404).json({ message: 'Route de livraison non trouvée' });
        }
        // Récupérer les points de livraison pour cette route
        const points = await database_1.default.query('SELECT * FROM delivery_points WHERE route_id = $1 ORDER BY sequence_order', [id]);
        route.rows[0].delivery_points = points.rows;
        res.json(route.rows[0]);
    }
    catch (error) {
        console.error('Erreur lors de la récupération de la route de livraison:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Récupérer tous les points de livraison
router.get('/points', async (req, res) => {
    try {
        const result = await database_1.default.query(`
      SELECT dp.*, dr.name as route_name, dr.day_of_week 
      FROM delivery_points dp
      JOIN delivery_routes dr ON dp.route_id = dr.id
      ORDER BY dr.id, dp.sequence_order
    `);
        res.json(result.rows);
    }
    catch (error) {
        console.error('Erreur lors de la récupération des points de livraison:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Récupérer un point de livraison par ID
router.get('/points/:id', async (req, res) => {
    const id = parseInt(req.params.id);
    try {
        const result = await database_1.default.query(`
      SELECT dp.*, dr.name as route_name, dr.day_of_week 
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
// 🚀 Récupérer une route par ID
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
        const errorMessage = error instanceof Error ? error.message : String(error);
        res.status(500).json({
            message: 'Erreur serveur',
            error: errorMessage
        });
    }
});
// 🚀 Ajouter une route
router.post('/', async (req, res) => {
    const { name, start_point, end_point, distance, estimated_time, is_active } = req.body;
    if (!name || !start_point || !end_point) {
        return res.status(400).json({ message: 'Nom, départ et arrivée sont requis' });
    }
    try {
        const result = await database_1.default.query('INSERT INTO routes (name, start_point, end_point, distance, estimated_time, is_active) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *', [name, start_point, end_point, distance, estimated_time, is_active ?? true]);
        res.status(201).json(result.rows[0]);
    }
    catch (error) {
        console.error('Erreur lors de la création de la route:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Mettre à jour une route
router.put('/:id', async (req, res) => {
    const id = parseInt(req.params.id);
    const { name, start_point, end_point, distance, estimated_time, is_active } = req.body;
    try {
        const result = await database_1.default.query('UPDATE routes SET name = $1, start_point = $2, end_point = $3, distance = $4, estimated_time = $5, is_active = $6 WHERE id = $7 RETURNING *', [name, start_point, end_point, distance, estimated_time, is_active, id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Route non trouvée' });
        }
        res.json(result.rows[0]);
    }
    catch (error) {
        console.error('Erreur lors de la mise à jour de la route:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// 🚀 Supprimer une route
router.delete('/:id', async (req, res) => {
    const id = parseInt(req.params.id);
    try {
        const result = await database_1.default.query('DELETE FROM routes WHERE id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Route non trouvée' });
        }
        res.json({ message: `Route ${id} supprimée`, route: result.rows[0] });
    }
    catch (error) {
        console.error('Erreur lors de la suppression de la route:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
exports.default = router;
