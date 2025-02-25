import React, { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';
import { Building2 } from 'lucide-react';

interface Region {
  id: string;
  name: string;
}

interface VisitRate {
  service: string;
  age_group: string;
  assumption_type: string;
  male_rate: number;
  female_rate: number;
}

interface PopulationData {
  region_id: string;
  population_type: string;
  default_factor: number;
  divisor: number;
  [key: string]: any;
}

interface SpecialtyRate {
  care_setting: string;
  specialty: string;
  virtual_rate: number;
  inperson_rate: number;
}

interface RoomRequirement {
  specialty: string;
  totalRooms: number;
  virtualRooms: number;
  inPersonRooms: number;
}

function OPDRoomRequirements() {
  const [loading, setLoading] = useState(true);
  const [regions, setRegions] = useState<Region[]>([]);
  const [selectedRegion, setSelectedRegion] = useState<string>('all');
  const [selectedYear, setSelectedYear] = useState(2025);
  const [selectedAssumption, setSelectedAssumption] = useState<'model' | 'enhanced' | 'high_risk'>('model');
  const [roomRequirements, setRoomRequirements] = useState<RoomRequirement[]>([]);

  const calculateRoomRequirements = (
    visitRates: VisitRate[],
    populationData: PopulationData[],
    specialtyRates: SpecialtyRate[],
    workingHours: any,
    availableDays: any,
    year: number
  ): RoomRequirement[] => {
    // Group visit rates by service
    const serviceVisits = new Map<string, number>();
    const ageGroups = ['0 to 4', '5 to 19', '20 to 29', '30 to 44', '45 to 64', '65 to 125'];

    // Calculate total visits per service
    visitRates.forEach(rate => {
      if (!serviceVisits.has(rate.service)) {
        serviceVisits.set(rate.service, 0);
      }

      // Calculate population for this age group
      const ageGroupPopulation = populationData
        .filter(pd => selectedRegion === 'all' || pd.region_id === selectedRegion)
        .reduce((sum, pd) => {
          const yearValue = pd[`year_${year}`] || 0;
          const calculatedValue = (yearValue * pd.default_factor) / pd.divisor;
          return sum + calculatedValue;
        }, 0);

      // Calculate visits using rates
      const maleVisits = (ageGroupPopulation * 0.5 * rate.male_rate) / 1000;
      const femaleVisits = (ageGroupPopulation * 0.5 * rate.female_rate) / 1000;
      const totalVisits = maleVisits + femaleVisits;

      serviceVisits.set(rate.service, serviceVisits.get(rate.service)! + totalVisits);
    });

    // Calculate room requirements
    const minutesPerYear = availableDays.available_days_per_year * workingHours.working_hours_per_day * 60;
    const requirements: RoomRequirement[] = [];

    serviceVisits.forEach((visits, service) => {
      const specialtyRate = specialtyRates.find(sr => sr.specialty === service);
      if (!specialtyRate) return;

      // Calculate virtual and in-person visits
      const virtualVisits = visits * specialtyRate.virtual_rate;
      const inPersonVisits = visits * specialtyRate.inperson_rate;

      // Calculate average visit duration (30 minutes for new, 20 for follow-up)
      const avgVisitDuration = 25; // Simplified average

      // Calculate total minutes needed
      const virtualMinutes = virtualVisits * avgVisitDuration;
      const inPersonMinutes = inPersonVisits * avgVisitDuration;

      // Calculate rooms needed
      const virtualRooms = Math.ceil(virtualMinutes / minutesPerYear);
      const inPersonRooms = Math.ceil(inPersonMinutes / minutesPerYear);

      requirements.push({
        specialty: service,
        virtualRooms,
        inPersonRooms,
        totalRooms: virtualRooms + inPersonRooms
      });
    });

    return requirements.sort((a, b) => b.totalRooms - a.totalRooms);
  };

  const fetchData = async () => {
    try {
      setLoading(true);

      // Fetch regions
      const { data: regionsData } = await supabase
        .from('regions')
        .select('id, name')
        .eq('is_neom', true)
        .eq('status', 'active');

      if (regionsData) {
        setRegions(regionsData);
      }

      // Fetch visit rates for selected assumption type
      const { data: visitRates } = await supabase
        .from('visit_rates')
        .select('*')
        .eq('assumption_type', selectedAssumption);

      // Fetch population data for selected region
      const { data: populationData } = await supabase
        .from('population_data')
        .select('*')
        .eq(selectedRegion !== 'all' ? 'region_id' : '', selectedRegion);

      // Fetch specialty occupancy rates
      const { data: specialtyRates } = await supabase
        .from('specialty_occupancy_rates')
        .select('*');

      // Fetch working hours for OPD
      const { data: workingHours } = await supabase
        .from('working_hours_settings')
        .select('*')
        .eq('care_setting', 'Specialist Outpatient Care')
        .single();

      // Fetch available days for OPD
      const { data: availableDays } = await supabase
        .from('available_days_settings')
        .select('*')
        .eq('care_setting', 'Specialist Outpatient Care')
        .single();

      if (!visitRates || !populationData || !specialtyRates || !workingHours || !availableDays) {
        throw new Error('Failed to fetch required data');
      }

      // Calculate room requirements
      const requirements = calculateRoomRequirements(
        visitRates,
        populationData,
        specialtyRates,
        workingHours,
        availableDays,
        selectedYear
      );

      setRoomRequirements(requirements);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [selectedRegion, selectedYear, selectedAssumption]);

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center space-x-2 mb-6">
          <Building2 className="h-6 w-6 text-emerald-600" />
          <h2 className="text-lg font-semibold text-gray-900">OPD Room Requirements</h2>
        </div>

        {/* Filters */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <select
            value={selectedRegion}
            onChange={(e) => setSelectedRegion(e.target.value)}
            className="rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
          >
            <option value="all">All Regions</option>
            {regions.map(region => (
              <option key={region.id} value={region.id}>{region.name}</option>
            ))}
          </select>

          <select
            value={selectedYear}
            onChange={(e) => setSelectedYear(parseInt(e.target.value))}
            className="rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
          >
            {Array.from({ length: 16 }, (_, i) => 2025 + i).map(year => (
              <option key={year} value={year}>{year}</option>
            ))}
          </select>

          <select
            value={selectedAssumption}
            onChange={(e) => setSelectedAssumption(e.target.value as 'model' | 'enhanced' | 'high_risk')}
            className="rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
          >
            <option value="model">Model</option>
            <option value="enhanced">Enhanced</option>
            <option value="high_risk">High Risk</option>
          </select>
        </div>

        {/* Results Table */}
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Specialty</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total Rooms</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Virtual Rooms</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">In-Person Rooms</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {roomRequirements.map((req, index) => (
                <tr key={index}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{req.specialty}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{req.totalRooms}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{req.virtualRooms}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{req.inPersonRooms}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

export default OPDRoomRequirements;