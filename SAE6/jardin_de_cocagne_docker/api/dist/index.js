"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
// Import routes
const basket_routes_1 = __importDefault(require("./routes/basket.routes"));
const product_routes_1 = __importDefault(require("./routes/product.routes"));
const route_routes_1 = __importDefault(require("./routes/route.routes"));
const subscription_routes_1 = __importDefault(require("./routes/subscription.routes"));
const delivery_points_routes_1 = __importDefault(require("./routes/delivery-points.routes"));
const delivery_points_routes_2 = __importDefault(require("./routes/delivery-points.routes")); // Updated route import
dotenv_1.default.config();
const app = (0, express_1.default)();
const port = process.env.PORT || process.env.API_PORT || 3000;
// Middleware
app.use((0, cors_1.default)());
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
// Routes
app.use('/api/baskets', basket_routes_1.default);
app.use('/api/products', product_routes_1.default);
app.use('/api/routes', route_routes_1.default);
app.use('/api/subscriptions', subscription_routes_1.default);
app.use('/api/delivery-points', delivery_points_routes_1.default);
app.use('/api/delivery-days', delivery_points_routes_2.default);
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
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Erreur serveur' });
});
// Start server
app.listen(port, () => {
    console.log(`Serveur en écoute sur le port ${port}`);
});
exports.default = app;
