import { useState, useEffect } from 'react';
import { Region, SubRegion, MapSettings } from '../types/regions';
import { api } from '../services/api';

export function useRegions() {
  const [regions, setRegions] = useState<Region[]>([]);
  const [subRegions, setSubRegions] = useState<SubRegion[]>([]);
  const [showInactive, setShowInactive] = useState(false);
  const [selectedRegion, setSelectedRegion] = useState<Region | null>(null);
  const [isAddingRegion, setIsAddingRegion] = useState(false);
  const [isAddingSubRegion, setIsAddingSubRegion] = useState(false);
  const [mapSettings, setMapSettings] = useState<MapSettings>({
    id: '',
    show_circles: false,
    circle_transparency: 50,
    circle_border: true,
    circle_radius_km: 10
  });
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);

  useEffect(() => {
    fetchRegions();
    fetchMapSettings();
  }, []);

  const fetchRegions = async () => {
    try {
      const regionsData = await api.get('/regions');
      setRegions(regionsData || []);

      const subRegionsData = await api.get('/subRegions');
      setSubRegions(subRegionsData || []);
    } catch (error) {
      console.error('Error fetching regions:', error);
    }
  };

  const fetchMapSettings = async () => {
    try {
      const data = await api.get('/mapSettings');
      if (data) {
        setMapSettings(data);
      }
    } catch (error) {
      console.error('Error fetching map settings:', error);
    }
  };

  const saveMapSettings = async (settings: MapSettings) => {
    try {
      const updatedSettings = await api.put(`/mapSettings/${settings.id}`, settings);
      setMapSettings(updatedSettings);
    } catch (error) {
      console.error('Error saving map settings:', error);
      throw error;
    }
  };

  const saveRegion = async (regionData: Partial<Region>) => {
    try {
      if (regionData.id) {
        // Update existing region
        await api.put(`/regions/${regionData.id}`, regionData);
      } else {
        // Create new region
        await api.post('/regions', regionData);
      }
      await fetchRegions();
    } catch (error) {
      console.error('Error saving region:', error);
      throw error;
    }
  };

  return {
    regions,
    subRegions,
    showInactive,
    setShowInactive,
    selectedRegion,
    setSelectedRegion,
    isAddingRegion,
    setIsAddingRegion,
    isAddingSubRegion,
    setIsAddingSubRegion,
    mapSettings,
    isSettingsOpen,
    setIsSettingsOpen,
    fetchRegions,
    fetchMapSettings,
    saveMapSettings,
    saveRegion
  };
}