import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Import routes
import basketRoutes from './routes/basket.routes';
import productRoutes from './routes/product.routes';
import routeRoutes from './routes/route.routes';
import subscriptionRoutes from './routes/subscription.routes';
import deliveryPointRoutes from './routes/delivery-points.routes';
import deliveryDaysRoutes from './routes/delivery-points.routes'; // Updated route import

dotenv.config();

const app = express();
const port = process.env.PORT || process.env.API_PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/baskets', basketRoutes);
app.use('/api/products', productRoutes);
app.use('/api/routes', routeRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/delivery-points', deliveryPointRoutes);
app.use('/api/delivery-days', deliveryDaysRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date() });
});

// Route de base
app.get('/api', (req, res) => {
  res.json({ message: 'API Jardin de Cocagne' });
});

// Gestion des erreurs
app.use((req, res, next) => {
  res.status(404).json({ message: 'Route non trouvée' });
});

app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Erreur serveur' });
});

// Start server
app.listen(port, () => {
  console.log(`Serveur en écoute sur le port ${port}`);
});

export default app;