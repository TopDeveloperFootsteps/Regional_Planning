import React, { useState } from 'react';
import { X, Settings, Ban } from 'lucide-react';
import { supabase } from '../../lib/supabase';

interface MapSettings {
  id: string;
  show_circles: boolean;
  circle_transparency: number;
  circle_border: boolean;
  circle_radius_km: number;
  icon_id?: string | null;
}

interface MapSettingsModalProps {
  isOpen: boolean;
  onClose: () => void;
  settings: MapSettings;
  onSave: (settings: MapSettings) => void;
  type: 'region' | 'sub_region';
}

export function MapSettingsModal({ 
  isOpen, 
  onClose, 
  settings,
  onSave,
  type: initialType
}: MapSettingsModalProps) {
  const [localSettings, setLocalSettings] = useState(settings);
  const [icons, setIcons] = useState<Array<{ id: string; name: string; url: string }>>([]);
  const [activeTab, setActiveTab] = useState<'region' | 'sub_region'>(initialType);
  const [loading, setLoading] = useState(false);

  React.useEffect(() => {
    fetchIcons();
  }, [activeTab]);

  const fetchIcons = async () => {
    const { data } = await supabase
      .from('map_icons')
      .select('*')
      .or(`icon_type.eq.${activeTab},icon_type.eq.both`)
      .eq('is_active', true);

    if (data) {
      setIcons(data);
    }
  };

  if (!isOpen) return null;

  const handleSettingChange = (key: keyof MapSettings, value: any) => {
    setLocalSettings(prev => ({
      ...prev,
      [key]: value
    }));
  };

  const handleSave = () => {
    onSave(localSettings);
    onClose();
  };

  // Helper function to get icon color class
  const getIconColorClass = (iconName: string) => {
    const name = iconName.toLowerCase();
    if (name.includes('blue')) return 'text-blue-500 fill-blue-500';
    if (name.includes('green')) return 'text-green-500 fill-green-500';
    if (name.includes('red')) return 'text-red-500 fill-red-500';
    return 'text-gray-500';
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-2xl max-h-[90vh] flex flex-col">
        <div className="flex justify-between items-center p-6 border-b border-gray-200">
          <div className="flex items-center space-x-2">
            <Settings className="h-5 w-5 text-emerald-600" />
            <h2 className="text-lg font-semibold text-gray-900">Map Settings</h2>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-500"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="border-b border-gray-200">
          <nav className="flex -mb-px">
            <button
              onClick={() => setActiveTab('region')}
              className={`px-6 py-3 border-b-2 text-sm font-medium ${
                activeTab === 'region'
                  ? 'border-emerald-500 text-emerald-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              Region Settings
            </button>
            <button
              onClick={() => setActiveTab('sub_region')}
              className={`px-6 py-3 border-b-2 text-sm font-medium ${
                activeTab === 'sub_region'
                  ? 'border-emerald-500 text-emerald-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              Sub-Region Settings
            </button>
          </nav>
        </div>

        <div className="flex-1 overflow-y-auto p-6">
          <div className="space-y-6">
            <div className="space-y-4">
              <h3 className="text-md font-medium text-gray-900">Display Settings</h3>
              
              <div className="flex items-center justify-between">
                <label className="text-sm text-gray-700">Show Circles</label>
                <input
                  type="checkbox"
                  checked={localSettings.show_circles}
                  onChange={(e) => handleSettingChange('show_circles', e.target.checked)}
                  className="h-4 w-4 text-emerald-600 focus:ring-emerald-500 border-gray-300 rounded"
                />
              </div>

              {localSettings.show_circles && (
                <>
                  <div className="space-y-2">
                    <label className="text-sm text-gray-700">Circle Transparency</label>
                    <input
                      type="range"
                      min="0"
                      max="100"
                      value={localSettings.circle_transparency}
                      onChange={(e) => handleSettingChange('circle_transparency', parseInt(e.target.value))}
                      className="w-full"
                    />
                    <div className="text-xs text-gray-500 text-right">{localSettings.circle_transparency}%</div>
                  </div>

                  <div className="flex items-center justify-between">
                    <label className="text-sm text-gray-700">Show Circle Border</label>
                    <input
                      type="checkbox"
                      checked={localSettings.circle_border}
                      onChange={(e) => handleSettingChange('circle_border', e.target.checked)}
                      className="h-4 w-4 text-emerald-600 focus:ring-emerald-500 border-gray-300 rounded"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm text-gray-700">Circle Radius (km)</label>
                    <input
                      type="range"
                      min="5"
                      max="100"
                      step="5"
                      value={localSettings.circle_radius_km}
                      onChange={(e) => handleSettingChange('circle_radius_km', parseInt(e.target.value))}
                      className="w-full"
                    />
                    <div className="text-xs text-gray-500 text-right">{localSettings.circle_radius_km} km</div>
                  </div>
                </>
              )}

              <div className="space-y-2">
                <label className="text-sm text-gray-700">Icon</label>
                <div className="grid grid-cols-6 gap-2">
                  {/* No Icon option */}
                  <button
                    onClick={() => handleSettingChange('icon_id', null)}
                    className={`p-2 border rounded-lg ${
                      localSettings.icon_id === null 
                        ? 'border-emerald-500 bg-emerald-50' 
                        : 'border-gray-200 hover:border-emerald-200'
                    }`}
                  >
                    <Ban className="w-6 h-6 mx-auto text-gray-400" />
                    <p className="text-[10px] text-center mt-1 text-gray-600 truncate">No Icon</p>
                  </button>
                  
                  {/* Icon options */}
                  {icons.map((icon) => (
                    <button
                      key={icon.id}
                      onClick={() => handleSettingChange('icon_id', icon.id)}
                      className={`p-2 border rounded-lg ${
                        localSettings.icon_id === icon.id 
                          ? 'border-emerald-500 bg-emerald-50' 
                          : 'border-gray-200 hover:border-emerald-200'
                      }`}
                    >
                      <img 
                        src={icon.url} 
                        alt={icon.name}
                        className={`w-6 h-6 mx-auto ${getIconColorClass(icon.name)}`}
                      />
                      <p className="text-[10px] text-center mt-1 text-gray-600 truncate">{icon.name}</p>
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="flex justify-end gap-3 px-6 py-4 bg-gray-50 border-t border-gray-200">
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            className="px-4 py-2 text-sm font-medium text-white bg-emerald-600 border border-transparent rounded-md hover:bg-emerald-700"
          >
            Save Changes
          </button>
        </div>
      </div>
    </div>
  );
}