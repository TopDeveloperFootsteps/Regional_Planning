import React from 'react';
import { Settings, Plus, ToggleLeft, ToggleRight } from 'lucide-react';

interface RegionsToolbarProps {
  showInactive: boolean;
  setShowInactive: (show: boolean) => void;
  setIsAddingRegion: (adding: boolean) => void;
  onOpenSettings: () => void;
}

export function RegionsToolbar({ 
  showInactive, 
  setShowInactive, 
  setIsAddingRegion,
  onOpenSettings
}: RegionsToolbarProps) {
  return (
    <div className="flex items-center space-x-4">
      <button
        onClick={() => setShowInactive(!showInactive)}
        className="flex items-center space-x-2 text-gray-600 hover:text-emerald-600"
      >
        {showInactive ? (
          <ToggleRight className="h-5 w-5" />
        ) : (
          <ToggleLeft className="h-5 w-5" />
        )}
        <span>Show Inactive</span>
      </button>
      <button
        onClick={() => setIsAddingRegion(true)}
        className="flex items-center space-x-2 px-4 py-2 bg-emerald-600 text-white rounded-md hover:bg-emerald-700"
      >
        <Plus className="h-4 w-4" />
        <span>Add Region</span>
      </button>
      <button
        onClick={onOpenSettings}
        className="flex items-center space-x-2 px-4 py-2 bg-gray-100 text-gray-600 rounded-md hover:bg-gray-200"
      >
        <Settings className="h-4 w-4" />
        <span>Settings</span>
      </button>
    </div>
  );
}