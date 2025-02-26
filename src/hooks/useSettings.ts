import { useState, useEffect } from 'react';
import { api } from '../services/api'; // Ensure you have the api service set up

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
      const regionData = await api.get('/useSettings/regionSettings'); // Adjust endpoint as needed
      setRegionSettings(regionData);

      // Fetch sub-region settings
      const subRegionData = await api.get('/useSettings/subRegionSettings'); // Adjust endpoint as needed
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
      if (regionSettings) {
        const updatedSettings = await api.put(`/useSettings/regionSettings/${regionSettings.id}`, settings);
        setRegionSettings(updatedSettings);
      }
    } catch (err) {
      console.error('Error updating region settings:', err);
      setError('Failed to update region settings');
      throw err;
    }
  };

  const updateSubRegionSettings = async (settings: Partial<MapSettings>) => {
    try {
      setError(null);
      if (subRegionSettings) {
        const updatedSettings = await api.put(`/useSettings/subRegionSettings/${subRegionSettings.id}`, settings); // Adjust endpoint as needed
        setSubRegionSettings(updatedSettings);
      }
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