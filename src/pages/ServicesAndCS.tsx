import { useState } from "react";
import { Header } from "../components/Header";
import { Footer } from "../components/Footer";
import { MappingInterface } from "../components/MappingInterface";
import { QuickLinks } from "../components/QuickLinks";
import { TableList } from "../components/TableList";
import { CareSettingOverview } from "../components/encounters/CareSettingOverview";
import { SystemOfCareDistribution } from "../components/encounters/SystemOfCareDistribution";
import { OptimizationAnalysis } from "../components/encounters/OptimizationAnalysis";
import { EncounterTrends } from "../components/encounters/EncounterTrends";
import { LoadingState } from "../components/encounters/LoadingState";
import { ErrorState } from "../components/encounters/ErrorState";
import { useEncountersData } from "../hooks/useEncountersData";
import { DCOutputAnalysis } from "../components/demand-capacity/DCOutputAnalysis";

type TabType = "services" | "care-settings" | "dc-output";

export function ServicesAndCS() {
  const [activeTab, setActiveTab] = useState<TabType>("services");

  const {
    loading,
    error,
    encounterStats,
    systemDistribution,
    optimizationData,
    retrying,
    handleRetry,
  } = useEncountersData();

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      <main className="flex-grow p-8">
        <div className="max-w-7xl mx-auto">
          {/* Overview Section */}
          <div className="bg-white rounded-lg shadow-sm p-8 mb-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-6">
              Services & Care Settings
            </h1>
            <p className="text-gray-600 mb-8">
              Manage healthcare services mapping, analyze care setting
              distributions, and evaluate demand and capacity requirements.
            </p>

            {/* Main Tabs */}
            <div className="border-b border-gray-200">
              <nav className="-mb-px flex space-x-8">
                <button
                  onClick={() => setActiveTab("services")}
                  className={`${
                    activeTab === "services"
                      ? "border-emerald-500 text-emerald-600"
                      : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
                  } whitespace-nowrap pb-4 px-1 border-b-2 font-medium text-sm`}
                >
                  Services Mapping
                </button>
                <button
                  onClick={() => setActiveTab("care-settings")}
                  className={`${
                    activeTab === "care-settings"
                      ? "border-emerald-500 text-emerald-600"
                      : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
                  } whitespace-nowrap pb-4 px-1 border-b-2 font-medium text-sm`}
                >
                  Care Settings
                </button>
                <button
                  onClick={() => setActiveTab("dc-output")}
                  className={`${
                    activeTab === "dc-output"
                      ? "border-emerald-500 text-emerald-600"
                      : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
                  } whitespace-nowrap pb-4 px-1 border-b-2 font-medium text-sm`}
                >
                  D&C Output Analysis
                </button>
              </nav>
            </div>
          </div>

          {/* Tab Content */}
          {activeTab === "services" && (
            <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
              <div className="lg:col-span-3 space-y-8">
                <MappingInterface />
              </div>
              <div className="lg:col-span-1 space-y-6">
                <QuickLinks />
                <TableList />
              </div>
            </div>
          )}

          {activeTab === "care-settings" && (
            <div className="space-y-8">
              {loading ? (
                <LoadingState />
              ) : error ? (
                <ErrorState
                  error={error}
                  onRetry={handleRetry}
                  retrying={retrying}
                />
              ) : (
                <>
                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    <CareSettingOverview stats={encounterStats} />
                    <SystemOfCareDistribution data={systemDistribution} />
                  </div>
                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    <EncounterTrends data={encounterStats} />
                    <OptimizationAnalysis data={optimizationData} />
                  </div>
                </>
              )}
            </div>
          )}

          {activeTab === "dc-output" && <DCOutputAnalysis />}
        </div>
      </main>
      <Footer />
    </div>
  );
}
