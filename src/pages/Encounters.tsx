import React from 'react';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { CareSettingOverview } from '../components/encounters/CareSettingOverview';
import { SystemOfCareDistribution } from '../components/encounters/SystemOfCareDistribution';
import { OptimizationAnalysis } from '../components/encounters/OptimizationAnalysis';
import { EncounterTrends } from '../components/encounters/EncounterTrends';
import { LoadingState } from '../components/encounters/LoadingState';
import { ErrorState } from '../components/encounters/ErrorState';
import { useEncountersData } from '../hooks/useEncountersData';

export function Encounters() {
  const {
    loading,
    error,
    encounterStats,
    systemDistribution,
    optimizationData,
    retrying,
    handleRetry
  } = useEncountersData();

  if (loading) {
    return <LoadingState />;
  }

  if (error) {
    return <ErrorState error={error} onRetry={handleRetry} retrying={retrying} />;
  }

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      <main className="flex-grow p-8">
        <div className="max-w-7xl mx-auto space-y-8">
          {/* Overview Section */}
          <div className="bg-white rounded-lg shadow-sm p-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-6">Care Settings Analysis</h1>
            <p className="text-gray-600 mb-8">
              Analyze and optimize healthcare delivery across different care settings to ensure 
              efficient resource utilization and improved patient outcomes. Monitor encounter 
              distributions and identify opportunities for care setting optimization.
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="bg-emerald-50 rounded-lg p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-3">Distribution Analysis</h2>
                <p className="text-gray-600">
                  Track encounter distribution across care settings and analyze patterns to 
                  identify areas for service delivery optimization.
                </p>
              </div>

              <div className="bg-emerald-50 rounded-lg p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-3">Care Setting Optimization</h2>
                <p className="text-gray-600">
                  Identify opportunities to shift care to more appropriate settings while 
                  maintaining quality and improving efficiency.
                </p>
              </div>
            </div>
          </div>

          {/* Statistics and Analysis */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <CareSettingOverview stats={encounterStats} />
            <SystemOfCareDistribution data={systemDistribution} />
          </div>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <EncounterTrends data={encounterStats} />
            <OptimizationAnalysis data={optimizationData} />
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}