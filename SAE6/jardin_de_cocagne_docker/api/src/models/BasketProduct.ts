export interface BasketProduct {
    id: number;
    basket_id: number;
    product_id: number;
    quantity: number;
    product_name?: string;
    category?: string;
    unit?: string;
    created_at?: Date;
    updated_at?: Date;
  }
  
  export interface CreateBasketProductDTO {
    basket_id: number;
    product_id: number;
    quantity: number;
  }
  
  export interface UpdateBasketProductDTO {
    quantity?: number;
  }