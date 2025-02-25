import React, { useState } from 'react';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Calculator, Building2, Clock } from 'lucide-react';
import { DemandAnalysis } from '../components/demand-capacity/DemandAnalysis';
import { CapacityAnalysis } from '../components/demand-capacity/CapacityAnalysis';
import { OPDCapacityCalculation } from '../components/demand-capacity/OPDCapacityCalculation';
import { InpatientCapacityCalculation } from '../components/demand-capacity/InpatientCapacityCalculation';

type TabType = 'demand' | 'capacity' | 'opd-capacity' | 'inpatient-capacity';

export function DemandCapacity() {
  const [activeTab, setActiveTab] = useState<TabType>('demand');

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      <main className="flex-grow p-8">
        <div className="max-w-7xl mx-auto space-y-8">
          {/* Overview Section */}
          <div className="bg-white rounded-lg shadow-sm p-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-6">Demand & Capacity Analysis</h1>
            <p className="text-gray-600 mb-8">
              Analyze healthcare demand patterns and capacity requirements across different regions and care settings. 
              Project future needs and optimize resource allocation based on population demographics and service utilization.
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="bg-emerald-50 rounded-lg p-6">
                <div className="flex items-center space-x-3 mb-3">
                  <Calculator className="h-6 w-6 text-emerald-600" />
                  <h2 className="text-xl font-semibold text-gray-900">Demand Analysis</h2>
                </div>
                <p className="text-gray-600">
                  Project healthcare service demand based on population demographics, utilization patterns, and regional factors.
                </p>
              </div>

              <div className="bg-emerald-50 rounded-lg p-6">
                <div className="flex items-center space-x-3 mb-3">
                  <Building2 className="h-6 w-6 text-emerald-600" />
                  <h2 className="text-xl font-semibold text-gray-900">Capacity Planning</h2>
                </div>
                <p className="text-gray-600">
                  Calculate required healthcare capacity and resources based on projected demand and service delivery standards.
                </p>
              </div>
            </div>
          </div>

          {/* Tabs */}
          <div className="border-b border-gray-200">
            <nav className="-mb-px flex space-x-8">
              <button
                onClick={() => setActiveTab('demand')}
                className={`${
                  activeTab === 'demand'
                    ? 'border-emerald-500 text-emerald-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                } whitespace-nowrap pb-4 px-1 border-b-2 font-medium text-sm flex items-center space-x-2`}
              >
                <Calculator className="h-5 w-5" />
                <span>Demand Analysis</span>
              </button>
              <button
                onClick={() => setActiveTab('capacity')}
                className={`${
                  activeTab === 'capacity'
                    ? 'border-emerald-500 text-emerald-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                } whitespace-nowrap pb-4 px-1 border-b-2 font-medium text-sm flex items-center space-x-2`}
              >
                <Building2 className="h-5 w-5" />
                <span>Capacity Analysis</span>
              </button>
              <button
                onClick={() => setActiveTab('opd-capacity')}
                className={`${
                  activeTab === 'opd-capacity'
                    ? 'border-emerald-500 text-emerald-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                } whitespace-nowrap pb-4 px-1 border-b-2 font-medium text-sm flex items-center space-x-2`}
              >
                <Clock className="h-5 w-5" />
                <span>OPD Capacity</span>
              </button>
              <button
                onClick={() => setActiveTab('inpatient-capacity')}
                className={`${
                  activeTab === 'inpatient-capacity'
                    ? 'border-emerald-500 text-emerald-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                } whitespace-nowrap pb-4 px-1 border-b-2 font-medium text-sm flex items-center space-x-2`}
              >
                <Building2 className="h-5 w-5" />
                <span>Inpatient Capacity</span>
              </button>
            </nav>
          </div>

          {/* Tab Content */}
          <div className="mt-6">
            {activeTab === 'demand' && <DemandAnalysis />}
            {activeTab === 'capacity' && <CapacityAnalysis />}
            {activeTab === 'opd-capacity' && <OPDCapacityCalculation />}
            {activeTab === 'inpatient-capacity' && <InpatientCapacityCalculation />}
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}