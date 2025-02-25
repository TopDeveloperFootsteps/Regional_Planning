import React, { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';
import { Table, Filter, ChevronUp, ChevronDown, Save } from 'lucide-react';

interface PlanningAnalysisProps {
  selectedPlan: string;
}

interface ActivitySummary {
  care_setting: string;
  total_activity: number;
  percentage: number;
}

interface ActivityDetails {
  care_setting: string;
  service: string;
  systems_of_care: string;
  code_count: number;
  total_activity: number;
  avg_activity_per_code: number;
}

interface ServiceAllocation {
  care_setting: string;
  current_distribution: number;
  proposed_distribution: number;
  total_activity: number;
}

const CARE_SETTINGS = [
  'HOME',
  'HEALTH STATION',
  'AMBULATORY SERVICE CENTER',
  'SPECIALTY CARE CENTER',
  'EXTENDED CARE FACILITY',
  'HOSPITAL'
];

export function PlanningAnalysis({ selectedPlan }: PlanningAnalysisProps) {
  const [activitySummary, setActivitySummary] = useState<ActivitySummary[]>([]);
  const [activityDetails, setActivityDetails] = useState<ActivityDetails[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedCareType, setSelectedCareType] = useState<string>('all');
  const [selectedService, setSelectedService] = useState<string>('all');
  const [uniqueServices, setUniqueServices] = useState<string[]>([]);
  const [serviceAllocation, setServiceAllocation] = useState<ServiceAllocation[]>([]);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    if (selectedPlan) {
      fetchActivityData();
    }
  }, [selectedPlan]);

  useEffect(() => {
    if (selectedService !== 'all') {
      initializeServiceAllocation();
    }
  }, [selectedService, activityDetails]);

  const fetchActivityData = async () => {
    try {
      setLoading(true);
      setError(null);

      const [summaryResult, detailsResult] = await Promise.all([
        supabase.from('care_setting_activity_summary').select('*'),
        supabase.from('care_setting_activity_details').select('*')
      ]);

      if (summaryResult.error) throw summaryResult.error;
      if (detailsResult.error) throw detailsResult.error;

      setActivitySummary(summaryResult.data || []);
      setActivityDetails(detailsResult.data || []);

      const services = [...new Set(detailsResult.data?.map(d => d.service) || [])];
      setUniqueServices(services.sort());

    } catch (err) {
      console.error('Error fetching activity data:', err);
      setError('Failed to load activity data');
    } finally {
      setLoading(false);
    }
  };

  const initializeServiceAllocation = () => {
    const serviceData = activityDetails.filter(d => d.service === selectedService);
    const totalServiceActivity = serviceData.reduce((sum, d) => sum + d.total_activity, 0);
    
    const allocation: ServiceAllocation[] = CARE_SETTINGS.map(setting => {
      const settingData = serviceData.find(d => d.care_setting === setting);
      const currentDistribution = settingData 
        ? (settingData.total_activity / totalServiceActivity) * 100 
        : 0;

      return {
        care_setting: setting,
        current_distribution: currentDistribution,
        proposed_distribution: currentDistribution,
        total_activity: settingData?.total_activity || 0
      };
    });

    setServiceAllocation(allocation);
  };

  const handleServiceAllocationChange = (careSetting: string, change: number) => {
    const currentValue = serviceAllocation.find(s => s.care_setting === careSetting)?.proposed_distribution || 0;
    const newValue = Math.round((currentValue + change) / 5) * 5; // Round to nearest 5%
    
    if (newValue >= 0 && newValue <= 100) {
      setServiceAllocation(prev => prev.map(item => 
        item.care_setting === careSetting 
          ? { ...item, proposed_distribution: newValue }
          : item
      ));
    }
  };

  const handleSaveAllocation = async () => {
    try {
      setIsSaving(true);
      
      // Validate total equals 100%
      const total = serviceAllocation.reduce((sum, item) => sum + item.proposed_distribution, 0);
      if (Math.round(total) !== 100) {
        throw new Error('Total proposed distribution must equal 100%');
      }

      // Save to database
      const { error } = await supabase
        .from('service_allocations')
        .upsert(
          serviceAllocation.map(item => ({
            plan_id: selectedPlan,
            service: selectedService,
            care_setting: item.care_setting,
            proposed_distribution: item.proposed_distribution
          }))
        );

      if (error) throw error;

      // Show success message
      alert('Service allocation saved successfully');
    } catch (err) {
      console.error('Error saving service allocation:', err);
      alert('Failed to save service allocation');
    } finally {
      setIsSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-32">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-red-600 p-4 text-center">
        {error}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-sm font-medium text-gray-700">Filters</h3>
          <Filter className="h-5 w-5 text-gray-400" />
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Care Setting
            </label>
            <select
              value={selectedCareType}
              onChange={(e) => setSelectedCareType(e.target.value)}
              className="w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
            >
              <option value="all">All Care Settings</option>
              {CARE_SETTINGS.map(setting => (
                <option key={setting} value={setting}>
                  {setting.replace(/_/g, ' ')}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Service
            </label>
            <select
              value={selectedService}
              onChange={(e) => setSelectedService(e.target.value)}
              className="w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
            >
              <option value="all">All Services</option>
              {uniqueServices.map(service => (
                <option key={service} value={service}>{service}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Service Allocation Table */}
      {selectedService !== 'all' && (
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center space-x-2">
              <Table className="h-6 w-6 text-emerald-600" />
              <h2 className="text-lg font-semibold text-gray-900">
                Service Allocation ({selectedService})
              </h2>
            </div>
            <button
              onClick={handleSaveAllocation}
              disabled={isSaving}
              className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-emerald-600 hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500 disabled:opacity-50"
            >
              <Save className="h-4 w-4 mr-2" />
              {isSaving ? 'Saving...' : 'Save Allocation'}
            </button>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Care Setting
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Current Distribution
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Proposed Distribution
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Total Activity
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {serviceAllocation.map((item) => (
                  <tr key={item.care_setting}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {item.care_setting.replace(/_/g, ' ')}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center space-x-2">
                        <div className="flex-grow bg-gray-200 rounded-full h-2">
                          <div
                            className="bg-emerald-500 h-2 rounded-full transition-all duration-300"
                            style={{ width: `${item.current_distribution}%` }}
                          />
                        </div>
                        <span className="text-sm text-gray-500 whitespace-nowrap">
                          {item.current_distribution.toFixed(1)}%
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center space-x-4">
                        <div className="flex-grow bg-gray-200 rounded-full h-2">
                          <div
                            className="bg-blue-500 h-2 rounded-full transition-all duration-300"
                            style={{ width: `${item.proposed_distribution}%` }}
                          />
                        </div>
                        <div className="flex items-center space-x-2">
                          <input
                            type="number"
                            value={item.proposed_distribution}
                            onChange={(e) => {
                              const value = Math.round(parseFloat(e.target.value) / 5) * 5;
                              if (!isNaN(value) && value >= 0 && value <= 100) {
                                setServiceAllocation(prev => prev.map(s => 
                                  s.care_setting === item.care_setting 
                                    ? { ...s, proposed_distribution: value }
                                    : s
                                ));
                              }
                            }}
                            className="w-20 text-right rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
                          />
                          <div className="flex flex-col">
                            <button
                              onClick={() => handleServiceAllocationChange(item.care_setting, 5)}
                              className="text-gray-500 hover:text-emerald-600"
                            >
                              <ChevronUp className="h-4 w-4" />
                            </button>
                            <button
                              onClick={() => handleServiceAllocationChange(item.care_setting, -5)}
                              className="text-gray-500 hover:text-emerald-600"
                            >
                              <ChevronDown className="h-4 w-4" />
                            </button>
                          </div>
                          <span className="text-sm text-gray-500">%</span>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {Math.round(item.total_activity).toLocaleString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Total Proposed Percentage */}
          <div className="mt-4 text-right text-sm text-gray-500">
            Total Proposed: {serviceAllocation.reduce((sum, item) => sum + item.proposed_distribution, 0)}%
            {Math.round(serviceAllocation.reduce((sum, item) => sum + item.proposed_distribution, 0)) !== 100 && (
              <span className="ml-2 text-red-500">
                (Must equal 100%)
              </span>
            )}
          </div>
        </div>
      )}

      {/* Activity Distribution Table */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center space-x-2 mb-6">
          <Table className="h-6 w-6 text-emerald-600" />
          <h2 className="text-lg font-semibold text-gray-900">Care Setting Activity Distribution</h2>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Care Setting
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Distribution
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Total Activity
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {CARE_SETTINGS.map((setting) => {
                const summary = activitySummary.find(s => s.care_setting === setting);
                const currentPercentage = summary?.percentage || 0;

                return (
                  <tr key={setting}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {setting.replace(/_/g, ' ')}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center space-x-2">
                        <div className="flex-grow bg-gray-200 rounded-full h-2">
                          <div
                            className="bg-emerald-500 h-2 rounded-full transition-all duration-300"
                            style={{ width: `${currentPercentage}%` }}
                          />
                        </div>
                        <span className="text-sm text-gray-500 whitespace-nowrap">
                          {currentPercentage.toFixed(1)}%
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {summary ? Math.round(summary.total_activity).toLocaleString() : 0}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}