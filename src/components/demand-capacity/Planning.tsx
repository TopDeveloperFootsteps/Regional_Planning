import React, { useState } from 'react';
import { Calendar, Monitor, DoorClosed, Layout, Filter, Bluetooth as Tooth,
  Ear, Eye, Siren, Ambulance, Bed, Activity, Brain, Baby, 
  HeartPulse, Stethoscope, FlaskRound as Flask, Radio, Scan, Microscope, Heart,
  Users, Table } from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { PlanningAnalysis } from './PlanningAnalysis';

interface PlanningData {
  id: string;
  name: string;
  population: number;
  date: string;
  capacity_data: any[];
  activity_data: any[];
}

interface ICDAnalysis {
  icd_family: string;
  total_activity: number;
  percentage_of_service: number;
  occurrence_count: number;
  care_settings: string[];
  systems_of_care: string[];
}

const CARE_TYPES = [
  'Primary Care',
  'Specialist Outpatient Care', 
  'Emergency Care',
  'Major Diagnostic & Treatment',
  'Day Cases',
  'Inpatient Care'
];

export function Planning() {
  const [plans, setPlans] = useState<PlanningData[]>([]);
  const [selectedPlan, setSelectedPlan] = useState<string>('');
  const [selectedCareType, setSelectedCareType] = useState<string>('all');
  const [selectedService, setSelectedService] = useState<string>('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [icdAnalysis, setIcdAnalysis] = useState<ICDAnalysis[]>([]);

  React.useEffect(() => {
    fetchPlans();
  }, []);

  React.useEffect(() => {
    if (selectedService) {
      fetchICDAnalysis();
    } else {
      setIcdAnalysis([]);
    }
  }, [selectedService]);

  const fetchPlans = async () => {
    try {
      setLoading(true);
      setError(null);

      const { data, error } = await supabase
        .from('dc_plans')
        .select('*')
        .order('date', { ascending: false });

      if (error) throw error;

      setPlans(data || []);
    } catch (err) {
      console.error('Error fetching plans:', err);
      setError('Failed to load plans');
    } finally {
      setLoading(false);
    }
  };

  const fetchICDAnalysis = async () => {
    try {
      const { data, error } = await supabase
        .from('top_icd_codes_by_service')
        .select('*')
        .eq('service', selectedService)
        .lte('rank', 20)
        .order('rank');

      if (error) throw error;
      setIcdAnalysis(data || []);
    } catch (err) {
      console.error('Error fetching ICD analysis:', err);
    }
  };

  const selectedPlanData = plans.find(p => p.id === selectedPlan);

  // Filter capacity data by care type
  const filteredCapacityData = selectedPlanData?.capacity_data.filter(item => 
    selectedCareType === 'all' || item.careType === selectedCareType
  ) || [];

  return (
    <div className="space-y-8">
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-lg font-semibold text-gray-900">Planning Analysis</h2>
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <Filter className="h-5 w-5 text-gray-400" />
              <select
                value={selectedCareType}
                onChange={(e) => setSelectedCareType(e.target.value)}
                className="rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
              >
                <option value="all">All Care Types</option>
                {CARE_TYPES.map(type => (
                  <option key={type} value={type}>{type}</option>
                ))}
              </select>
            </div>
            <select
              value={selectedService}
              onChange={(e) => setSelectedService(e.target.value)}
              className="rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
            >
              <option value="">Select a Service</option>
              {Array.from(new Set(filteredCapacityData.map(item => item.service))).sort().map(service => (
                <option key={service} value={service}>{service}</option>
              ))}
            </select>
            <select
              value={selectedPlan}
              onChange={(e) => setSelectedPlan(e.target.value)}
              className="rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
            >
              <option value="">Select a plan</option>
              {plans.map(plan => (
                <option key={plan.id} value={plan.id}>
                  {plan.name} ({new Date(plan.date).toLocaleDateString()})
                </option>
              ))}
            </select>
          </div>
        </div>

        {loading ? (
          <div className="flex items-center justify-center h-32">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
          </div>
        ) : error ? (
          <div className="text-center py-8 text-red-600">
            {error}
          </div>
        ) : selectedPlan ? (
          <div className="space-y-6">
            {/* Plan Info */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
              <div className="bg-emerald-50 rounded-lg p-4">
                <div className="flex items-center space-x-3">
                  <Calendar className="h-8 w-8 text-emerald-600" />
                  <div>
                    <p className="text-sm font-medium text-gray-600">Plan Date</p>
                    <p className="text-2xl font-bold text-gray-900">
                      {new Date(selectedPlanData?.date || '').toLocaleDateString()}
                    </p>
                  </div>
                </div>
              </div>
              <div className="bg-emerald-50 rounded-lg p-4">
                <div className="flex items-center space-x-3">
                  <Users className="h-8 w-8 text-emerald-600" />
                  <div>
                    <p className="text-sm font-medium text-gray-600">Population</p>
                    <p className="text-2xl font-bold text-gray-900">
                      {selectedPlanData?.population.toLocaleString()}
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Planning Analysis Table */}
            <PlanningAnalysis selectedPlan={selectedPlan} />

            {/* ICD Analysis Table */}
            {selectedService && icdAnalysis.length > 0 && (
              <div className="mt-8">
                <h3 className="text-lg font-medium text-gray-900 mb-4">
                  Top ICD Codes for {selectedService}
                </h3>
                <div className="overflow-x-auto">
                  <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          ICD Family
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Activity
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          % of Service
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Care Settings
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Systems of Care
                        </th>
                      </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                      {icdAnalysis.map((analysis, index) => (
                        <tr key={index}>
                          <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                            {analysis.icd_family}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            {Math.round(analysis.total_activity).toLocaleString()}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            {analysis.percentage_of_service}%
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            {analysis.care_settings.join(', ')}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            {analysis.systems_of_care.join(', ')}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {/* Capacity Requirements Table */}
            {selectedPlanData?.capacity_data.length > 0 && (
              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-4">Capacity Requirements</h3>
                <div className="overflow-x-auto">
                  <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Care Type</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Reason for Visit / Specialty</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Capacity Type</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Inperson</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Virtual</th>
                      </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                      {filteredCapacityData.map((row: any, index: number) => (
                        <tr key={index}>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.careType}</td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.reasonForVisit}</td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.capacityType}</td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.inperson.toLocaleString(undefined, {maximumFractionDigits: 2})}</td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.virtual.toLocaleString(undefined, {maximumFractionDigits: 2})}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {/* Activity Data */}
            {selectedPlanData?.activity_data.length > 0 && (
              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-4">Activity/Demand</h3>
                <div className="overflow-x-auto">
                  <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Care Type</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Reason for Visit / Specialty</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Capacity Type</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Inperson</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Virtual</th>
                      </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                      {selectedPlanData.activity_data.map((row: any, index: number) => (
                        <tr key={index}>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.careType}</td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.reasonForVisit}</td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.capacityType}</td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.inperson.toLocaleString(undefined, {maximumFractionDigits: 2})}</td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.virtual.toLocaleString(undefined, {maximumFractionDigits: 2})}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </div>
        ) : (
          <div className="text-center py-12 text-gray-500">
            Select a plan to view analysis
          </div>
        )}
      </div>
    </div>
  );
}