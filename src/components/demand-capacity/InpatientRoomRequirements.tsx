import React from 'react';
import { Building2 } from 'lucide-react';

export function InpatientRoomRequirements() {
  return (
    <div className="space-y-8">
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center space-x-2 mb-6">
          <Building2 className="h-6 w-6 text-emerald-600" />
          <h2 className="text-lg font-semibold text-gray-900">Inpatient Room Requirements</h2>
        </div>
        <p className="text-gray-600">
          This section will calculate inpatient room requirements based on:
          - Bed occupancy rates
          - Average length of stay
          - Annual admissions by specialty
          - Bed turnover intervals
        </p>
      </div>
    </div>
  );
}