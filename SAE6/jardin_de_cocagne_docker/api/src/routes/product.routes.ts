import { Router } from 'express';
import db from '../config/database'; // Connexion à PostgreSQL

const router = Router();

// 🚀 Récupérer tous les produits
router.get('/', async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM products');
    res.json(result.rows);
  } catch (error) {
    console.error('Erreur lors de la récupération des produits:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// 🚀 Récupérer un produit par ID
router.get('/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  try {
    const result = await db.query('SELECT * FROM products WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Produit non trouvé' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du produit:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// 🚀 Ajouter un produit
router.post('/', async (req, res) => {
  const { name, price_per_kg, category, unit, image_url } = req.body;

  if (!name || !price_per_kg || !unit) {
    return res.status(400).json({ message: 'Nom, prix et unité sont requis' });
  }

  try {
    const result = await db.query(
      'INSERT INTO products (name, price_per_kg, category, unit, image_url) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [name, price_per_kg, category, unit, image_url]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Erreur lors de l\'ajout du produit:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// 🚀 Mettre à jour un produit
router.put('/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  const { name, price_per_kg, category, unit, image_url } = req.body;

  try {
    const result = await db.query(
      'UPDATE products SET name = $1, price_per_kg = $2, category = $3, unit = $4, image_url = $5 WHERE id = $6 RETURNING *',
      [name, price_per_kg, category, unit, image_url, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Produit non trouvé' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erreur lors de la mise à jour du produit:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// 🚀 Supprimer un produit
router.delete('/:id', async (req, res) => {
  const id = parseInt(req.params.id);

  try {
    const result = await db.query('DELETE FROM products WHERE id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Produit non trouvé' });
    }

    res.json({ message: `Produit ${id} supprimé`, product: result.rows[0] });
  } catch (error) {
    console.error('Erreur lors de la suppression du produit:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

export default router;
