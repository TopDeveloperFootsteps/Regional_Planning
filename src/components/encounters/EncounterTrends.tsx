import React from 'react';
import { TrendingUp, FileText } from 'lucide-react';

interface EncounterStats {
  care_setting: string;
  record_count: number;
  encounter_count: number;
  icd_code_count?: number;
  system_distribution?: Record<string, number>;
  top_icd_codes?: Array<{
    icd_family_code: string;
    description: string;
    encounters: number;
    percentage: number;
  }>;
}

interface EncounterTrendsProps {
  data: EncounterStats[];
}

export function EncounterTrends({ data }: EncounterTrendsProps) {
  const totalEncounters = data.reduce((sum, item) => sum + item.encounter_count, 0);

  // Sort data by encounter count in descending order
  const sortedData = [...data].sort((a, b) => b.encounter_count - a.encounter_count);

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center space-x-2 mb-6">
        <TrendingUp className="h-6 w-6 text-emerald-600" />
        <h2 className="text-lg font-semibold text-gray-900">Encounter Distribution Trends</h2>
      </div>
      <div className="space-y-6">
        {/* Care Setting Distribution */}
        <div className="space-y-4">
          <h3 className="text-sm font-medium text-gray-700">Care Setting Distribution</h3>
          {sortedData.map((item) => (
            <div key={item.care_setting} className="space-y-2">
              <div className="flex justify-between items-baseline">
                <span className="text-sm font-medium text-gray-700">{item.care_setting}</span>
                <div className="text-right">
                  <span className="text-sm text-gray-900">{item.encounter_count.toLocaleString()}</span>
                  <span className="text-xs text-gray-500 ml-2">
                    ({((item.encounter_count / totalEncounters) * 100).toFixed(1)}%)
                  </span>
                </div>
              </div>
              <div className="flex items-center space-x-4">
                <div className="flex-grow bg-gray-200 rounded-full h-2">
                  <div
                    className="bg-emerald-500 h-2 rounded-full transition-all duration-300"
                    style={{ width: `${(item.encounter_count / totalEncounters) * 100}%` }}
                  />
                </div>
                <div className="text-xs text-gray-500 whitespace-nowrap">
                  {item.icd_code_count?.toLocaleString() || 0} ICD codes
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Top ICD Family Codes */}
        {data[0]?.top_icd_codes && (
          <div className="mt-8 space-y-4">
            <div className="flex items-center space-x-2">
              <FileText className="h-5 w-5 text-emerald-600" />
              <h3 className="text-sm font-medium text-gray-700">Top ICD Family Codes</h3>
            </div>
            <div className="space-y-3">
              {data[0].top_icd_codes.map((code) => (
                <div key={code.icd_family_code} className="space-y-2">
                  <div className="flex justify-between items-baseline">
                    <div>
                      <span className="text-sm font-medium text-gray-700">{code.icd_family_code}</span>
                      {code.description && code.description !== 'No description available' && (
                        <span className="text-xs text-gray-500 ml-2">({code.description})</span>
                      )}
                    </div>
                    <div className="text-right">
                      <span className="text-sm text-gray-900">{code.encounters.toLocaleString()}</span>
                      <span className="text-xs text-gray-500 ml-2">({code.percentage.toFixed(1)}%)</span>
                    </div>
                  </div>
                  <div className="flex-grow bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-emerald-500 h-2 rounded-full transition-all duration-300"
                      style={{ width: `${code.percentage}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}