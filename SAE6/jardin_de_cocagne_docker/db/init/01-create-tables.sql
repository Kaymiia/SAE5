-- Create products table
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  price_per_kg DECIMAL(10, 2) NOT NULL,
  category VARCHAR(100),
  unit VARCHAR(50) NOT NULL,
  image_url VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create baskets table
CREATE TABLE baskets (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  description TEXT,
  image_url VARCHAR(255),
  weight VARCHAR(50),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create basket_products table (for n-m relationship)
CREATE TABLE basket_products (
  id SERIAL PRIMARY KEY,
  basket_id INTEGER NOT NULL REFERENCES baskets(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  quantity DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(basket_id, product_id)
);

-- Create delivery_routes table
CREATE TABLE delivery_routes (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  day_of_week VARCHAR(20) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create delivery_points table
CREATE TABLE delivery_points (
  id SERIAL PRIMARY KEY,
  route_id INTEGER NOT NULL REFERENCES delivery_routes(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  address TEXT NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  sequence_order INTEGER NOT NULL,
  estimated_arrival_time TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create users table (simplified)
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone VARCHAR(20),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create user_subscriptions table
CREATE TABLE user_subscriptions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  basket_id INTEGER NOT NULL REFERENCES baskets(id) ON DELETE RESTRICT,
  delivery_point_id INTEGER NOT NULL REFERENCES delivery_points(id) ON DELETE RESTRICT,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, basket_id)
);

-- Add indexes for performance
CREATE INDEX idx_basket_products_basket_id ON basket_products(basket_id);
CREATE INDEX idx_basket_products_product_id ON basket_products(product_id);
CREATE INDEX idx_delivery_points_route_id ON delivery_points(route_id);
CREATE INDEX idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX idx_user_subscriptions_basket_id ON user_subscriptions(basket_id);
CREATE INDEX idx_user_subscriptions_delivery_point_id ON user_subscriptions(delivery_point_id);