export interface Region {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  status: 'active' | 'inactive';
  is_neom: boolean;
}

export interface SubRegion {
  id: string;
  region_id: string;
  name: string;
  latitude: number;
  longitude: number;
  status: 'active' | 'inactive';
}

export interface MapSettings {
  id: string;
  show_circles: boolean;
  circle_transparency: number;
  circle_border: boolean;
  circle_radius_km: number;
}

export interface RegionSettings {
  id: string;
  circle_radius_km: number;
  show_circles: boolean;
  circle_transparency: number;
  circle_border: boolean;
}

export interface SubRegionSettings {
  id: string;
  circle_radius_km: number;
  show_circles: boolean;
  circle_transparency: number;
  circle_border: boolean;
}