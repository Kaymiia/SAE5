export interface Subscription {
    id: number;
    user_id: number;
    basket_id: number;
    delivery_point_id: number;
    status: string; // 'active', 'suspended', 'cancelled'
    created_at: Date;
    updated_at: Date;
    
    // Propriétés jointes
    basket_name: string;
    price: number;
    weight?: string;
    image_url?: string;
    delivery_point_name: string;
    route_name: string;
    frequency: string; // jour de la semaine (Lundi, Mardi, etc.)
  }
  
  export interface CreateSubscriptionDTO {
    user_id: number;
    basket_id: number;
    delivery_point_id: number;
    status?: string;
  }
  
  export interface UpdateSubscriptionDTO {
    user_id?: number;
    basket_id?: number;
    delivery_point_id?: number;
    status?: string;
  }
  
  export interface UpdateSubscriptionStatusDTO {
    status: string;
  }