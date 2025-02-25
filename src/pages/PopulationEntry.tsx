import React, { useState } from 'react';
import { useRegions } from '../hooks/useRegions';
import { AgeGroupDistribution } from '../components/population/AgeGroupDistribution';
import { GenderDistribution } from '../components/population/GenderDistribution';
import { PopulationTypeEntry } from '../components/population/PopulationTypeEntry';
import { ChevronDown } from 'lucide-react';

export function PopulationEntry() {
  const { regions } = useRegions();
  const [selectedRegion, setSelectedRegion] = useState<string>('');

  const neomRegions = regions.filter(r => r.status === 'active' && r.is_neom);

  return (
    <div className="space-y-8">
      {/* Overview Section */}
      <div className="bg-white rounded-lg shadow-sm p-8">
        <h2 className="text-2xl font-semibold text-gray-900 mb-6">Population Data Entry</h2>
        <p className="text-gray-600 mb-8">
          Manage and update population data for each region. Enter and modify population distributions 
          across age groups, gender, and population types to maintain accurate demographic records.
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-emerald-50 rounded-lg p-6">
            <h3 className="text-xl font-semibold text-gray-900 mb-3">Population Data Management</h3>
            <p className="text-gray-600">
              Enter and update population data by age groups, gender, and population types for each region to maintain 
              accurate demographic information.
            </p>
          </div>

          <div className="bg-emerald-50 rounded-lg p-6">
            <h3 className="text-xl font-semibold text-gray-900 mb-3">Distribution Tables</h3>
            <p className="text-gray-600">
              View and edit population distribution tables to ensure accurate representation of 
              demographic segments.
            </p>
          </div>
        </div>
      </div>

      {/* Region Selection */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-semibold text-gray-900">Region Population Data</h3>
          <div className="relative">
            <select
              value={selectedRegion}
              onChange={(e) => setSelectedRegion(e.target.value)}
              className="appearance-none block w-64 px-4 py-2 rounded-lg border border-gray-300 bg-white text-gray-700 hover:border-emerald-500 focus:outline-none focus:ring-2 focus:ring-emerald-500"
            >
              <option value="">Select Region</option>
              {neomRegions.map(region => (
                <option key={region.id} value={region.id}>{region.name}</option>
              ))}
            </select>
            <ChevronDown className="absolute right-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400 pointer-events-none" />
          </div>
        </div>

        {selectedRegion ? (
          <div className="space-y-8">
            <PopulationTypeEntry selectedRegion={selectedRegion} />
            <AgeGroupDistribution />
            <GenderDistribution />
          </div>
        ) : (
          <div className="text-center py-12 text-gray-500">
            Please select a region to view and edit population data
          </div>
        )}
      </div>
    </div>
  );
}