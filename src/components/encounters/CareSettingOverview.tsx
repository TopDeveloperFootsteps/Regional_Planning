import React from 'react';
import { Activity, Building2, Home, Guitar as Hospital, Building, Stethoscope, ChevronFirst as FirstAid } from 'lucide-react';
import { systemsOfCare } from '../../data';

interface EncounterStats {
  care_setting: string;
  record_count: number;
  encounter_count: number;
  system_distribution?: Record<string, number>;
}

interface CareSettingOverviewProps {
  stats: EncounterStats[];
}

// Helper function for care setting icons
const getCareSettingIcon = (setting: string) => {
  switch (setting) {
    case 'Home':
      return <Home className="h-5 w-5 text-gray-400" />;
    case 'Health Station':
      return <FirstAid className="h-5 w-5 text-gray-400" />;
    case 'Ambulatory Service Center':
      return <Building2 className="h-5 w-5 text-gray-400" />;
    case 'Specialty Care Center':
      return <Stethoscope className="h-5 w-5 text-gray-400" />;
    case 'Extended Care Facility':
      return <Building className="h-5 w-5 text-gray-400" />;
    case 'Hospital':
      return <Hospital className="h-5 w-5 text-gray-400" />;
    default:
      return <Building2 className="h-5 w-5 text-gray-400" />;
  }
};

// Care setting order
const CARE_SETTING_ORDER = [
  'Home',
  'Health Station',
  'Ambulatory Service Center',
  'Specialty Care Center',
  'Extended Care Facility',
  'Hospital'
];

export function CareSettingOverview({ stats }: CareSettingOverviewProps) {
  // Calculate total encounters for percentage calculation
  const totalEncounters = stats.reduce((sum, stat) => sum + stat.encounter_count, 0);

  // Sort stats according to defined order
  const sortedStats = [...stats].sort((a, b) => {
    const indexA = CARE_SETTING_ORDER.indexOf(a.care_setting);
    const indexB = CARE_SETTING_ORDER.indexOf(b.care_setting);
    return indexA - indexB;
  });

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center space-x-2 mb-6">
        <Activity className="h-6 w-6 text-emerald-600" />
        <h2 className="text-lg font-semibold text-gray-900">Care Setting Overview</h2>
      </div>
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Care Setting</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-48">Distribution</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {sortedStats.map((stat) => {
              // Calculate percentage of total encounters
              const percentage = totalEncounters > 0 
                ? (stat.encounter_count / totalEncounters) * 100 
                : 0;

              return (
                <tr key={stat.care_setting}>
                  <td className="px-6 py-4">
                    <div className="space-y-2">
                      <div className="flex items-center space-x-3">
                        {getCareSettingIcon(stat.care_setting)}
                        <span className="text-sm text-gray-900">{stat.care_setting}</span>
                      </div>
                      {stat.system_distribution && (
                        <div className="pl-8 space-y-1">
                          {systemsOfCare.map(system => (
                            <div key={system} className="flex items-center justify-between text-xs">
                              <span className="text-gray-600">{system}</span>
                              <span className="text-gray-500">
                                {stat.system_distribution[system]?.toFixed(1)}%
                              </span>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center space-x-2">
                      <div className="flex-grow bg-gray-200 rounded-full h-2">
                        <div 
                          className="bg-emerald-500 h-2 rounded-full transition-all duration-300" 
                          style={{ width: `${percentage}%` }}
                        />
                      </div>
                      <span className="text-xs text-gray-500 whitespace-nowrap">
                        {percentage.toFixed(1)}%
                      </span>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}