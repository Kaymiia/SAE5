import db from '../config/database';
import { Product, CreateProductDTO, UpdateProductDTO } from '../models/Product';
import { BasketProduct } from '../models/BasketProduct';

export default {
  /**
   * Get all products
   */
  async getAllProducts(activeOnly: boolean = true): Promise<Product[]> {
    const query = `
      SELECT * FROM products
      ${activeOnly ? 'WHERE is_active = true' : ''}
      ORDER BY name
    `;
    
    const { rows } = await db.query(query);
    return rows;
  },

  /**
   * Get product by ID
   */
  async getProductById(id: number): Promise<Product | null> {
    const query = `
      SELECT * FROM products
      WHERE id = $1
    `;
    
    const { rows } = await db.query(query, [id]);
    return rows.length ? rows[0] : null;
  },

  /**
   * Create new product
   */
  async createProduct(product: CreateProductDTO): Promise<Product> {
    const query = `
      INSERT INTO products (
        name, price_per_kg, category, unit, image_url, is_active
      ) VALUES (
        $1, $2, $3, $4, $5, $6
      ) RETURNING *
    `;
    
    const values = [
      product.name,
      product.price_per_kg,
      product.category || null,
      product.unit,
      product.image_url || null,
      product.is_active !== undefined ? product.is_active : true
    ];
    
    const { rows } = await db.query(query, values);
    return rows[0];
  },

  /**
   * Update product
   */
  async updateProduct(id: number, product: UpdateProductDTO): Promise<Product | null> {
    // First check if product exists
    const existingProduct = await this.getProductById(id);
    if (!existingProduct) return null;
    
    // Build the query dynamically based on what fields are being updated
    const updates: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;
    
    if (product.name !== undefined) {
      updates.push(`name = $${paramIndex}`);
      values.push(product.name);
      paramIndex++;
    }
    
    if (product.price_per_kg !== undefined) {
      updates.push(`price_per_kg = $${paramIndex}`);
      values.push(product.price_per_kg);
      paramIndex++;
    }
    
    if (product.category !== undefined) {
      updates.push(`category = $${paramIndex}`);
      values.push(product.category);
      paramIndex++;
    }
    
    if (product.unit !== undefined) {
      updates.push(`unit = $${paramIndex}`);
      values.push(product.unit);
      paramIndex++;
    }
    
    if (product.image_url !== undefined) {
      updates.push(`image_url = $${paramIndex}`);
      values.push(product.image_url);
      paramIndex++;
    }
    
    if (product.is_active !== undefined) {
      updates.push(`is_active = $${paramIndex}`);
      values.push(product.is_active);
      paramIndex++;
    }
    
    // Always update the updated_at timestamp
    updates.push(`updated_at = NOW()`);
    
    // If no fields to update, return the existing product
    if (updates.length === 1) return existingProduct;
    
    const query = `
      UPDATE products
      SET ${updates.join(', ')}
      WHERE id = $${paramIndex}
      RETURNING *
    `;
    
    values.push(id);
    
    const { rows } = await db.query(query, values);
    return rows[0];
  },

  /**
   * Delete product (soft delete by setting is_active to false)
   */
  async deleteProduct(id: number): Promise<boolean> {
    const query = `
      UPDATE products
      SET is_active = false, updated_at = NOW()
      WHERE id = $1
      RETURNING id
    `;
    
    const { rows } = await db.query(query, [id]);
    return rows.length > 0;
  },

  /**
   * Get products by basket ID
   */
  async getProductsByBasketId(basketId: number): Promise<BasketProduct[]> {
    const query = `
      SELECT bp.id, bp.basket_id, bp.product_id, bp.quantity, 
             p.name as product_name, p.category, p.unit
      FROM basket_products bp
      JOIN products p ON bp.product_id = p.id
      WHERE bp.basket_id = $1
    `;
    
    const { rows } = await db.query(query, [basketId]);
    return rows;
  }
};