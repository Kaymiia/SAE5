export interface Product {
    id: number;
    name: string;
    price_per_kg: number;
    category?: string;
    unit: string;
    image_url?: string;
    is_active: boolean;
    created_at: Date;
    updated_at: Date;
  }
  
  export interface CreateProductDTO {
    name: string;
    price_per_kg: number;
    category?: string;
    unit: string;
    image_url?: string;
    is_active?: boolean;
  }
  
  export interface UpdateProductDTO {
    name?: string;
    price_per_kg?: number;
    category?: string;
    unit?: string;
    image_url?: string;
    is_active?: boolean;
  }