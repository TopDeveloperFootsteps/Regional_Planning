import React from 'react';
import OPDRoomRequirements from './OPDRoomRequirements';
import { InpatientRoomRequirements } from './InpatientRoomRequirements';

export function CapacityAnalysis() {
  const [activeTab, setActiveTab] = React.useState<'opd' | 'inpatient'>('opd');

  return (
    <div className="space-y-8">
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8">
            <button
              onClick={() => setActiveTab('opd')}
              className={`${
                activeTab === 'opd'
                  ? 'border-emerald-500 text-emerald-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              } whitespace-nowrap pb-4 px-1 border-b-2 font-medium text-sm`}
            >
              OPD Room Requirements
            </button>
            <button
              onClick={() => setActiveTab('inpatient')}
              className={`${
                activeTab === 'inpatient'
                  ? 'border-emerald-500 text-emerald-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              } whitespace-nowrap pb-4 px-1 border-b-2 font-medium text-sm`}
            >
              Inpatient Room Requirements
            </button>
          </nav>
        </div>

        <div className="mt-6">
          {activeTab === 'opd' ? <OPDRoomRequirements /> : <InpatientRoomRequirements />}
        </div>
      </div>
    </div>
  );
}