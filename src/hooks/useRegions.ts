import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { Region, SubRegion, MapSettings } from '../types/regions';

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
      const { data: regionsData, error: regionsError } = await supabase
        .from('regions')
        .select('*')
        .order('name');

      if (regionsError) throw regionsError;
      setRegions(regionsData || []);

      const { data: subRegionsData, error: subRegionsError } = await supabase
        .from('sub_regions')
        .select('*')
        .order('name');

      if (subRegionsError) throw subRegionsError;
      setSubRegions(subRegionsData || []);
    } catch (error) {
      console.error('Error fetching regions:', error);
    }
  };

  const fetchMapSettings = async () => {
    try {
      const { data, error } = await supabase
        .from('map_settings')
        .select('*')
        .limit(1)
        .single();

      if (error) throw error;
      if (data) {
        setMapSettings(data);
      }
    } catch (error) {
      console.error('Error fetching map settings:', error);
    }
  };

  const saveMapSettings = async (settings: MapSettings) => {
    try {
      const { error } = await supabase
        .from('map_settings')
        .update({
          show_circles: settings.show_circles,
          circle_transparency: settings.circle_transparency,
          circle_border: settings.circle_border,
          circle_radius_km: settings.circle_radius_km
        })
        .eq('id', settings.id);

      if (error) throw error;
      setMapSettings(settings);
    } catch (error) {
      console.error('Error saving map settings:', error);
      throw error;
    }
  };

  const saveRegion = async (regionData: Partial<Region>) => {
    try {
      if (regionData.id) {
        // Update existing region
        const { error } = await supabase
          .from('regions')
          .update({
            name: regionData.name,
            latitude: regionData.latitude,
            longitude: regionData.longitude,
            status: regionData.status,
            is_neom: regionData.is_neom
          })
          .eq('id', regionData.id);

        if (error) throw error;
      } else {
        // Create new region
        const { error } = await supabase
          .from('regions')
          .insert([{
            name: regionData.name,
            latitude: regionData.latitude,
            longitude: regionData.longitude,
            status: 'active',
            is_neom: regionData.is_neom
          }]);

        if (error) throw error;
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