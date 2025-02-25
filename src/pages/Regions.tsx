import React from 'react';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Map } from 'lucide-react';
import { RegionsTable } from '../components/regions/RegionsTable';
import { RegionsToolbar } from '../components/regions/RegionsToolbar';
import { MapComponent } from '../components/MapComponent';
import { MapSettingsModal } from '../components/regions/MapSettingsModal';
import { RegionForm } from '../components/regions/RegionForm';
import { useRegions } from '../hooks/useRegions';
import { useSettings } from '../hooks/useSettings';

export function Regions() {
  const {
    regions,
    subRegions,
    showInactive,
    setShowInactive,
    selectedRegion,
    setSelectedRegion,
    isAddingRegion,
    setIsAddingRegion,
    isSettingsOpen,
    setIsSettingsOpen,
    saveRegion
  } = useRegions();

  const {
    regionSettings,
    subRegionSettings,
    loading,
    error,
    updateRegionSettings,
    updateSubRegionSettings
  } = useSettings();

  const [settingsType, setSettingsType] = React.useState<'region' | 'sub_region'>('region');
  const [activeMap, setActiveMap] = React.useState<'enhanced' | 'basic'>('enhanced');

  if (loading || !regionSettings || !subRegionSettings) {
    return <div>Loading settings...</div>;
  }

  if (error) {
    return <div>Error loading settings: {error}</div>;
  }

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      <main className="flex-grow p-8">
        <div className="max-w-7xl mx-auto space-y-8">
          {/* Overview Section */}
          <div className="bg-white rounded-lg shadow-sm p-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-6">Regional Planning</h1>
            <p className="text-gray-600 mb-8">
              Manage and visualize healthcare regions and sub-regions to optimize service coverage 
              and accessibility. Plan and monitor healthcare infrastructure distribution across 
              different geographical areas.
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="bg-emerald-50 rounded-lg p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-3">Geographic Coverage</h2>
                <p className="text-gray-600">
                  Define and manage healthcare regions and sub-regions to ensure comprehensive 
                  coverage and optimal service distribution.
                </p>
              </div>

              <div className="bg-emerald-50 rounded-lg p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-3">Infrastructure Planning</h2>
                <p className="text-gray-600">
                  Plan and visualize healthcare infrastructure placement to maximize accessibility 
                  and service efficiency.
                </p>
              </div>
            </div>
          </div>

          {/* Regions Management */}
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex justify-between items-center mb-6">
              <div className="flex items-center space-x-2">
                <Map className="h-6 w-6 text-emerald-600" />
                <h2 className="text-2xl font-bold text-gray-900">Regions Management</h2>
              </div>
              <RegionsToolbar 
                showInactive={showInactive}
                setShowInactive={setShowInactive}
                setIsAddingRegion={setIsAddingRegion}
                onOpenSettings={() => {
                  setSettingsType('region');
                  setIsSettingsOpen(true);
                }}
              />
            </div>

            <RegionsTable 
              regions={regions}
              showInactive={showInactive}
              onRegionSelect={setSelectedRegion}
            />

            {/* Map Type Selector */}
            <div className="mt-8 mb-4">
              <div className="flex space-x-4">
                <button
                  onClick={() => setActiveMap('enhanced')}
                  className={`px-4 py-2 rounded-lg ${
                    activeMap === 'enhanced'
                      ? 'bg-emerald-600 text-white'
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  }`}
                >
                  Enhanced Map
                </button>
                <button
                  onClick={() => setActiveMap('basic')}
                  className={`px-4 py-2 rounded-lg ${
                    activeMap === 'basic'
                      ? 'bg-emerald-600 text-white'
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  }`}
                >
                  Basic Map
                </button>
              </div>
            </div>

            {/* Enhanced Map */}
            {activeMap === 'enhanced' && (
              <div className="h-96 bg-gray-100 rounded-lg mb-4">
                <MapComponent
                  regions={regions}
                  subRegions={subRegions}
                  mapSettings={regionSettings}
                  showInactive={showInactive}
                  onRegionClick={setSelectedRegion}
                />
              </div>
            )}

            {/* Basic Map */}
            {activeMap === 'basic' && (
              <div className="h-96 bg-gray-100 rounded-lg">
                <MapComponent
                  regions={regions}
                  subRegions={subRegions}
                  mapSettings={{
                    show_circles: true,
                    circle_transparency: 50,
                    circle_border: true,
                    circle_radius_km: 10
                  }}
                  showInactive={showInactive}
                  onRegionClick={setSelectedRegion}
                />
              </div>
            )}
          </div>
        </div>
      </main>
      <Footer />

      <MapSettingsModal
        isOpen={isSettingsOpen}
        onClose={() => setIsSettingsOpen(false)}
        settings={settingsType === 'region' ? regionSettings : subRegionSettings}
        onSave={settingsType === 'region' ? updateRegionSettings : updateSubRegionSettings}
        type={settingsType}
      />

      <RegionForm
        isOpen={isAddingRegion || !!selectedRegion}
        onClose={() => {
          setIsAddingRegion(false);
          setSelectedRegion(null);
        }}
        onSave={saveRegion}
        region={selectedRegion || undefined}
      />
    </div>
  );
}