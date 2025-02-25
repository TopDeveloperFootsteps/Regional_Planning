import React from 'react';
import { TrendingDown } from 'lucide-react';

interface OptimizationData {
  care_setting: string;
  current_encounters: number;
  current_percentage: number;
  shift_potential: number;
  shift_direction: string;
  potential_shift_percentage: number;
  proposed_percentage: number;
  potential_encounters_change: number;
  optimization_strategy: string;
}

interface OptimizationAnalysisProps {
  data: OptimizationData[];
}

export function OptimizationAnalysis({ data }: OptimizationAnalysisProps) {
  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center space-x-2 mb-6">
        <TrendingDown className="h-6 w-6 text-emerald-600" />
        <h2 className="text-lg font-semibold text-gray-900">Care Setting Optimization Analysis</h2>
      </div>
      <div className="space-y-6">
        {data.map((item) => (
          <div key={item.care_setting} className="border-b border-gray-200 pb-4 last:border-0">
            <div className="flex justify-between items-start mb-2">
              <h3 className="text-md font-semibold text-gray-800">{item.care_setting}</h3>
              <div className="text-sm text-gray-500">
                Current: {item.current_percentage}% → Proposed: {item.proposed_percentage}%
              </div>
            </div>
            <div className="flex items-center space-x-2 mb-2">
              <div className="flex-grow bg-gray-200 rounded-full h-2">
                <div
                  className="bg-emerald-500 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${item.current_percentage}%` }}
                />
              </div>
              <span className="text-xs text-gray-500 whitespace-nowrap">
                {item.current_encounters.toLocaleString()} encounters
              </span>
            </div>
            {item.shift_potential > 0 && (
              <div className="mt-2 p-2 bg-emerald-50 rounded-md">
                <p className="text-sm text-emerald-700">
                  Potential shift: {item.potential_shift_percentage}% ({item.shift_potential.toLocaleString()} encounters)
                </p>
                <p className="text-xs text-gray-600 mt-1">{item.optimization_strategy}</p>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}