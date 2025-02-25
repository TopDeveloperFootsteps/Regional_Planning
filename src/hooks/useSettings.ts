import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

interface MapSettings {
  id: string;
  show_circles: boolean;
  circle_transparency: number;
  circle_border: boolean;
  circle_radius_km: number;
  icon_id?: string;
}

export function useSettings() {
  const [regionSettings, setRegionSettings] = useState<MapSettings | null>(null);
  const [subRegionSettings, setSubRegionSettings] = useState<MapSettings | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    try {
      setLoading(true);
      setError(null);

      // Fetch region settings
      const { data: regionData, error: regionError } = await supabase
        .from('region_settings')
        .select('*')
        .single();

      if (regionError) throw regionError;

      // Fetch sub-region settings
      const { data: subRegionData, error: subRegionError } = await supabase
        .from('sub_region_settings')
        .select('*')
        .single();

      if (subRegionError) throw subRegionError;

      setRegionSettings(regionData);
      setSubRegionSettings(subRegionData);
    } catch (err) {
      console.error('Error fetching settings:', err);
      setError('Failed to load settings');
    } finally {
      setLoading(false);
    }
  };

  const updateRegionSettings = async (settings: Partial<MapSettings>) => {
    try {
      setError(null);
      const { error } = await supabase
        .from('region_settings')
        .update(settings)
        .eq('id', regionSettings?.id);

      if (error) throw error;
      await fetchSettings();
    } catch (err) {
      console.error('Error updating region settings:', err);
      setError('Failed to update region settings');
      throw err;
    }
  };

  const updateSubRegionSettings = async (settings: Partial<MapSettings>) => {
    try {
      setError(null);
      const { error } = await supabase
        .from('sub_region_settings')
        .update(settings)
        .eq('id', subRegionSettings?.id);

      if (error) throw error;
      await fetchSettings();
    } catch (err) {
      console.error('Error updating sub-region settings:', err);
      setError('Failed to update sub-region settings');
      throw err;
    }
  };

  return {
    regionSettings,
    subRegionSettings,
    loading,
    error,
    updateRegionSettings,
    updateSubRegionSettings,
    fetchSettings
  };
}