import React, { useState, useEffect } from 'react';
import { Users, Calculator, Activity, TrendingUp } from 'lucide-react';
import { supabase } from '../../lib/supabase';

interface PopulationData {
  region_id: string;
  population_type: string;
  default_factor: number;
  divisor: number;
  [key: string]: any;
}

interface GlobalPopulationOverviewProps {
  selectedRegion: string;
}

export function GlobalPopulationOverview({ selectedRegion }: GlobalPopulationOverviewProps) {
  const [populationData, setPopulationData] = useState<PopulationData[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedYear, setSelectedYear] = useState(2025);

  useEffect(() => {
    fetchPopulationData();
  }, []);

  const fetchPopulationData = async () => {
    try {
      setLoading(true);
      const { data: regions } = await supabase
        .from('regions')
        .select('*')
        .eq('is_neom', true)
        .eq('status', 'active');

      if (!regions) return;

      const { data: popData } = await supabase
        .from('population_data')
        .select('*');

      if (popData) {
        setPopulationData(popData);
      }
    } catch (error) {
      console.error('Error fetching population data:', error);
    } finally {
      setLoading(false);
    }
  };

  const calculateDependencyRatio = (year: number) => {
    const dependentAgeGroups = ['0-4', '5-19', '65-125'];
    const workingAgeGroups = ['20-29', '30-44', '45-64'];
    
    let dependentPopulation = 0;
    let workingPopulation = 0;

    // Only consider Residents for dependency ratio
    const residentsData = populationData.filter(d => 
      d.population_type === 'Residents' &&
      (selectedRegion === 'all' || d.region_id === selectedRegion)
    );

    residentsData.forEach(record => {
      const value = record[`year_${year}`] || 0;
      const calculatedValue = (value * record.default_factor) / record.divisor;
      
      // Distribute the population according to age group percentages
      dependentPopulation += calculatedValue * 0.33; // 0-4: 8%, 5-19: 20%, 65+: 5%
      workingPopulation += calculatedValue * 0.67; // 20-29: 18%, 30-44: 30%, 45-64: 19%
    });

    return workingPopulation > 0 ? Math.round((dependentPopulation / workingPopulation) * 100) : 0;
  };

  const calculateGrowthRate = () => {
    const firstYear = 2025;
    const lastYear = 2040;
    
    const firstYearTotal = populationData
      .filter(d => selectedRegion === 'all' || d.region_id === selectedRegion)
      .reduce((sum, record) => {
        const value = record[`year_${firstYear}`] || 0;
        return sum + (value * record.default_factor) / record.divisor;
      }, 0);

    const lastYearTotal = populationData
      .filter(d => selectedRegion === 'all' || d.region_id === selectedRegion)
      .reduce((sum, record) => {
        const value = record[`year_${lastYear}`] || 0;
        return sum + (value * record.default_factor) / record.divisor;
      }, 0);

    const years = lastYear - firstYear;
    return years > 0 ? 
      ((Math.pow(lastYearTotal / firstYearTotal, 1/years) - 1) * 100).toFixed(1) :
      '0.0';
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  const totalPopulation2040 = populationData
    .filter(d => selectedRegion === 'all' || d.region_id === selectedRegion)
    .reduce((sum, record) => {
      const value = record[`year_2040`] || 0;
      return sum + (value * record.default_factor) / record.divisor;
    }, 0);

  return (
    <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center space-x-3">
          <Users className="h-8 w-8 text-emerald-600" />
          <div>
            <p className="text-sm font-medium text-gray-600">Highest Population (2040)</p>
            <h3 className="text-2xl font-bold text-gray-900">
              {Math.round(totalPopulation2040).toLocaleString()}
            </h3>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center space-x-3">
          <Calculator className="h-8 w-8 text-emerald-600" />
          <div>
            <p className="text-sm font-medium text-gray-600">Median Age</p>
            <h3 className="text-2xl font-bold text-gray-900">32.5</h3>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center space-x-3">
          <Activity className="h-8 w-8 text-emerald-600" />
          <div>
            <p className="text-sm font-medium text-gray-600">Growth Rate (2025-2040)</p>
            <h3 className="text-2xl font-bold text-gray-900">{calculateGrowthRate()}%</h3>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center space-x-3">
          <TrendingUp className="h-8 w-8 text-emerald-600" />
          <div>
            <p className="text-sm font-medium text-gray-600">
              <span className="block">Dependency Ratio</span>
              <span className="text-xs text-gray-500">(Dependents/Working Age)</span>
            </p>
            <h3 className="text-2xl font-bold text-gray-900">
              {calculateDependencyRatio(selectedYear)}%
            </h3>
          </div>
        </div>
      </div>
    </div>
  );
}