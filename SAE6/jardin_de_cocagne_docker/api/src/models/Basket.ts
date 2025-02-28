import { BasketProduct } from './BasketProduct';

export interface Basket {
  id: number;
  name: string;
  price: number;
  description?: string;
  image_url?: string;
  weight?: string;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
  products?: BasketProduct[];
}

export interface CreateBasketDTO {
  name: string;
  price: number;
  description?: string;
  image_url?: string;
  weight?: string;
  is_active?: boolean;
}

export interface UpdateBasketDTO {
  name?: string;
  price?: number;
  description?: string;
  image_url?: string;
  weight?: string;
  is_active?: boolean;
}