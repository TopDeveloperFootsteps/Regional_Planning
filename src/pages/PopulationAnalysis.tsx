import React, { useState, useEffect } from 'react';
import { ChevronDown, ChevronRight, Table } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { GlobalPopulationOverview } from '../components/population/GlobalPopulationOverview';
import { PopulationDetails } from '../components/population/PopulationDetails';
import { PopulationSummary } from '../components/population/PopulationSummary';
import { PopulationGrowthChart } from '../components/population/PopulationGrowthChart';
import { AgeDistributionChart } from '../components/population/AgeDistributionChart';
import { PopulationPyramid } from '../components/population/PopulationPyramid';

interface RegionInfo {
  id: string;
  name: string;
}

interface PopulationTrend {
  year: number;
  [key: string]: number | string;
}

interface AgeDistributionData {
  ageGroup: string;
  male: number;
  female: number;
}

const YEARS = Array.from({ length: 16 }, (_, i) => 2025 + i);
const AGE_GROUPS = ['0 to 4', '5 to 19', '20 to 29', '30 to 44', '45 to 64', '65 to 125'];

export function PopulationAnalysis() {
  const [regions, setRegions] = useState<RegionInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedYear, setSelectedYear] = useState(2025);
  const [selectedRegion, setSelectedRegion] = useState<string>('all');
  const [showDetails, setShowDetails] = useState(false);
  const [populationTrends, setPopulationTrends] = useState<PopulationTrend[]>([]);
  const [ageDistribution, setAgeDistribution] = useState<AgeDistributionData[]>([]);

  useEffect(() => {
    fetchData();
  }, []);

  useEffect(() => {
    if (populationTrends.length > 0) {
      calculateAgeDistribution();
    }
  }, [selectedYear, populationTrends]);

  const fetchData = async () => {
    try {
      setLoading(true);
      
      const { data: popData } = await supabase
        .from('population_data')
        .select('*');

      if (popData) {
        const { data: regionsData } = await supabase
          .from('regions')
          .select('id, name')
          .eq('is_neom', true)
          .eq('status', 'active')
          .in('id', [...new Set(popData.map(pd => pd.region_id))]);

        if (regionsData) {
          setRegions(regionsData);
          generatePopulationTrends(regionsData, popData);
        }
      }
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  const generatePopulationTrends = (regionsData: RegionInfo[], populationData: any[]) => {
    const trends: PopulationTrend[] = [];

    YEARS.forEach(year => {
      const yearData: PopulationTrend = { year };

      regionsData.forEach(region => {
        const totalPopulation = populationData
          .filter(pd => pd.region_id === region.id)
          .reduce((sum, record) => {
            const value = record[`year_${year}`] || 0;
            const calculatedValue = (value * record.default_factor) / record.divisor;
            return sum + calculatedValue;
          }, 0);

        yearData[region.name] = Math.round(totalPopulation);
      });

      trends.push(yearData);
    });

    setPopulationTrends(trends);
  };

  const calculateAgeDistribution = () => {
    const distribution: AgeDistributionData[] = AGE_GROUPS.map(ageGroup => {
      let maleTotal = 0;
      let femaleTotal = 0;

      regions.forEach(region => {
        const yearData = populationTrends.find(pt => pt.year === selectedYear);
        if (yearData) {
          const totalPopulation = yearData[region.name] as number;
          
          // Age group distribution
          let ageGroupPercentage;
          if (ageGroup === '0 to 4') ageGroupPercentage = 0.08;
          else if (ageGroup === '5 to 19') ageGroupPercentage = 0.20;
          else if (ageGroup === '20 to 29') ageGroupPercentage = 0.18;
          else if (ageGroup === '30 to 44') ageGroupPercentage = 0.30;
          else if (ageGroup === '45 to 64') ageGroupPercentage = 0.19;
          else ageGroupPercentage = 0.05; // 65 to 125

          // Gender distribution
          const malePercentage = ageGroup === '65 to 125' ? 0.48 : 0.52;
          const ageGroupPopulation = totalPopulation * ageGroupPercentage;
          
          maleTotal += ageGroupPopulation * malePercentage;
          femaleTotal += ageGroupPopulation * (1 - malePercentage);
        }
      });

      return {
        ageGroup,
        male: Math.round(maleTotal),
        female: Math.round(femaleTotal)
      };
    });

    setAgeDistribution(distribution);
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <GlobalPopulationOverview selectedRegion={selectedRegion} />

      {/* Population Summary Table */}
      <PopulationSummary />

      {/* Collapsible Population Details */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <button
          onClick={() => setShowDetails(!showDetails)}
          className="flex items-center justify-between w-full text-left hover:bg-gray-50 p-2 rounded-lg transition-colors"
        >
          <div className="flex items-center space-x-2">
            <Table className="h-6 w-6 text-emerald-600" />
            <h2 className="text-xl font-semibold text-gray-900">Population Details</h2>
          </div>
          {showDetails ? (
            <ChevronDown className="h-5 w-5 text-gray-500" />
          ) : (
            <ChevronRight className="h-5 w-5 text-gray-500" />
          )}
        </button>
        
        <div className={`mt-4 transition-all duration-300 ${showDetails ? 'block' : 'hidden'}`}>
          <PopulationDetails />
        </div>
      </div>

      {/* Charts Section */}
      <div className="space-y-8">
        {/* Population Growth Trend */}
        <PopulationGrowthChart 
          data={populationTrends}
          regions={regions}
        />

        {/* Age Distribution and Population Pyramid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <AgeDistributionChart data={ageDistribution} />
          <PopulationPyramid data={ageDistribution} />
        </div>
      </div>
    </div>
  );
}