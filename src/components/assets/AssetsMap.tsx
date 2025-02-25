import React, { useState, useEffect } from 'react';
import { MapComponent } from '../MapComponent';
import { Filter, HelpCircle } from 'lucide-react';

interface Asset {
  id: string;
  name: string;
  type: string;
  owner: string;
  archetype: string;
  latitude: number;
  longitude: number;
  status: string;
}

interface AssetFilters {
  type?: string;
  archetype?: string;
  owner?: string;
  status?: string;
}

interface AssetsMapProps {
  assets: Asset[];
  loading: boolean;
}

export function AssetsMap({ assets, loading }: AssetsMapProps) {
  const [filters, setFilters] = useState<AssetFilters>({});
  const [showFilters, setShowFilters] = useState(false);
  const [showLegend, setShowLegend] = useState(true);
  const [filteredAssets, setFilteredAssets] = useState<Asset[]>([]);

  // Apply filters whenever assets or filters change
  useEffect(() => {
    const filtered = assets.filter(asset => {
      const typeMatch = !filters.type || asset.type === filters.type;
      const archetypeMatch = !filters.archetype || asset.archetype === filters.archetype;
      const ownerMatch = !filters.owner || asset.owner === filters.owner;
      const statusMatch = !filters.status || asset.status === filters.status;
      return typeMatch && archetypeMatch && ownerMatch && statusMatch;
    });
    setFilteredAssets(filtered);
  }, [assets, filters]);

  if (loading) {
    return (
      <div className="h-[600px] flex items-center justify-center bg-gray-100 rounded-lg">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Header with Controls */}
      <div className="flex justify-between items-center">
        <div className="flex items-center space-x-4">
          <h2 className="text-lg font-semibold text-gray-900">Assets Map</h2>
          <button
            onClick={() => setShowLegend(!showLegend)}
            className="flex items-center space-x-2 text-sm text-gray-600 hover:text-emerald-600"
          >
            <HelpCircle className="h-4 w-4" />
            <span>{showLegend ? 'Hide Legend' : 'Show Legend'}</span>
          </button>
        </div>
        <button
          onClick={() => setShowFilters(!showFilters)}
          className="flex items-center space-x-2 px-4 py-2 text-sm font-medium text-gray-600 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
        >
          <Filter className="h-4 w-4" />
          <span>Filters</span>
        </button>
      </div>

      {/* Legend */}
      {showLegend && (
        <div className="bg-white p-4 rounded-lg border border-gray-200 space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Archetype Shapes */}
            <div>
              <h3 className="text-sm font-medium text-gray-700 mb-2">Asset Types</h3>
              <div className="space-y-2">
                <div className="flex items-center space-x-2">
                  <svg className="h-4 w-4" viewBox="0 0 16 16">
                    <rect x="4" y="4" width="8" height="8" transform="rotate(45 8 8)" fill="#9CA3AF" stroke="#6B7280" strokeWidth="2"/>
                  </svg>
                  <span className="text-sm text-gray-600">Hospital</span>
                </div>
                <div className="flex items-center space-x-2">
                  <svg className="h-4 w-4" viewBox="0 0 16 16">
                    <polygon points="8,2 14,8 8,14 2,8" fill="#9CA3AF" stroke="#6B7280" strokeWidth="2"/>
                  </svg>
                  <span className="text-sm text-gray-600">Hub</span>
                </div>
                <div className="flex items-center space-x-2">
                  <svg className="h-4 w-4" viewBox="0 0 16 16">
                    <polygon points="8,2 10,7 15,7 11,10 13,15 8,12 3,15 5,10 1,7 6,7" fill="#9CA3AF" stroke="#6B7280" strokeWidth="1"/>
                  </svg>
                  <span className="text-sm text-gray-600">Spoke</span>
                </div>
                <div className="flex items-center space-x-2">
                  <svg className="h-4 w-4" viewBox="0 0 16 16">
                    <rect x="4" y="4" width="8" height="8" fill="#9CA3AF" stroke="#6B7280" strokeWidth="2"/>
                  </svg>
                  <span className="text-sm text-gray-600">Health Center</span>
                </div>
                <div className="flex items-center space-x-2">
                  <svg className="h-4 w-4" viewBox="0 0 16 16">
                    <polygon points="8,2 13,12 3,12" fill="#9CA3AF" stroke="#6B7280" strokeWidth="2"/>
                  </svg>
                  <span className="text-sm text-gray-600">First Aid Point</span>
                </div>
                <div className="flex items-center space-x-2">
                  <svg className="h-4 w-4" viewBox="0 0 16 16">
                    <path d="M8,2 L14,8 L8,14 L2,8 Z M5,8 L11,8 M8,5 L8,11" fill="#9CA3AF" stroke="#6B7280" strokeWidth="1"/>
                  </svg>
                  <span className="text-sm text-gray-600">Clinic</span>
                </div>
              </div>
            </div>

            {/* Status Colors */}
            <div>
              <h3 className="text-sm font-medium text-gray-700 mb-2">Status Colors</h3>
              <div className="space-y-2">
                <div className="flex items-center space-x-2">
                  <div className="h-4 w-4 rounded-full bg-emerald-600"></div>
                  <span className="text-sm text-gray-600">Operational</span>
                </div>
                <div className="flex items-center space-x-2">
                  <div className="h-4 w-4 rounded-full bg-amber-600"></div>
                  <span className="text-sm text-gray-600">Partially Operational</span>
                </div>
                <div className="flex items-center space-x-2">
                  <div className="h-4 w-4 rounded-full bg-gray-500"></div>
                  <span className="text-sm text-gray-600">Not Started</span>
                </div>
                <div className="flex items-center space-x-2">
                  <div className="h-4 w-4 rounded-full bg-blue-600"></div>
                  <span className="text-sm text-gray-600">Design/Planning</span>
                </div>
                <div className="flex items-center space-x-2">
                  <div className="h-4 w-4 rounded-full bg-gray-400"></div>
                  <span className="text-sm text-gray-600">Other</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Filters Panel */}
      {showFilters && (
        <div className="bg-white p-4 rounded-lg border border-gray-200 space-y-4">
          {/* Type Filter */}
          <div>
            <label className="block text-sm font-medium text-gray-700">Type of Asset</label>
            <select
              value={filters.type || ''}
              onChange={(e) => setFilters(prev => ({ ...prev, type: e.target.value || undefined }))}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
            >
              <option value="">All Types</option>
              <option value="Permanent">Permanent</option>
              <option value="Temporary">Temporary</option>
              <option value="PPP">PPP</option>
              <option value="MoH">MoH</option>
            </select>
          </div>

          {/* Archetype Filter */}
          <div>
            <label className="block text-sm font-medium text-gray-700">Asset Archetype</label>
            <select
              value={filters.archetype || ''}
              onChange={(e) => setFilters(prev => ({ ...prev, archetype: e.target.value || undefined }))}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
            >
              <option value="">All Archetypes</option>
              <option value="Family Health Center">Family Health Center</option>
              <option value="Resort">Resort</option>
              <option value="Spoke">Spoke</option>
              <option value="Field Hospital">Field Hospital</option>
              <option value="N/A">N/A</option>
              <option value="Advance Health Center">Advance Health Center</option>
              <option value="Hub">Hub</option>
              <option value="First Aid Point">First Aid Point</option>
              <option value="Clinic">Clinic</option>
              <option value="Hospital">Hospital</option>
            </select>
          </div>

          {/* Owner Filter */}
          <div>
            <label className="block text-sm font-medium text-gray-700">Owner</label>
            <select
              value={filters.owner || ''}
              onChange={(e) => setFilters(prev => ({ ...prev, owner: e.target.value || undefined }))}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
            >
              <option value="">All Owners</option>
              <option value="Neom">Neom</option>
              <option value="MoD">MoD</option>
              <option value="Construction Camp">Construction Camp</option>
              <option value="AlBassam">AlBassam</option>
              <option value="Nessma">Nessma</option>
              <option value="Tamasuk">Tamasuk</option>
              <option value="Alfanar">Alfanar</option>
              <option value="Almutlaq">Almutlaq</option>
              <option value="MoH">MoH</option>
            </select>
          </div>

          {/* Status Filter */}
          <div>
            <label className="block text-sm font-medium text-gray-700">Status</label>
            <select
              value={filters.status || ''}
              onChange={(e) => setFilters(prev => ({ ...prev, status: e.target.value || undefined }))}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
            >
              <option value="">All Statuses</option>
              <option value="Design">Design</option>
              <option value="Planning">Planning</option>
              <option value="Operational">Operational</option>
              <option value="Not Started">Not Started</option>
              <option value="Partially Operational">Partially Operational</option>
            </select>
          </div>
        </div>
      )}

      {/* Map */}
      <div className="h-[600px] bg-gray-100 rounded-lg">
        <MapComponent
          regions={[]}
          subRegions={[]}
          mapSettings={{
            show_circles: false,
            circle_transparency: 50,
            circle_border: true,
            circle_radius_km: 10
          }}
          showInactive={false}
          assets={filteredAssets}
        />
      </div>

      {/* Asset Count */}
      <div className="text-sm text-gray-600">
        Showing {filteredAssets.length} of {assets.length} assets
      </div>
    </div>
  );
}