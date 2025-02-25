import React, { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';
import { ServiceDemandAnalysis } from './ServiceDemandAnalysis';
import { ServiceVisitsBreakdown } from './ServiceVisitsBreakdown';
import { Filter } from 'lucide-react';

interface ServiceVisits {
  service: string;
  visits: number;
  maleVisits: number;
  femaleVisits: number;
}

const AGE_GROUPS = ['0 to 4', '5 to 19', '20 to 29', '30 to 44', '45 to 64', '65 to 125'];

const SERVICES = [
  'Primary dental care',
  'Routine health checks',
  'Acute & urgent care',
  'Chronic metabolic diseases',
  'Chronic respiratory diseases',
  'Chronic mental health disorders',
  'Other chronic diseases',
  'Complex condition / Frail elderly',
  'Maternal Care',
  'Well baby care (0 to 4)',
  'Paediatric care (5 to 16)',
  'Allied Health & Health Promotion'
];

export function DemandAnalysis() {
  const [loading, setLoading] = useState(true);
  const [regions, setRegions] = useState<Array<{ id: string; name: string }>>([]);
  const [selectedRegion, setSelectedRegion] = useState<string>('all');
  const [selectedYear, setSelectedYear] = useState(2025);
  const [selectedAssumption, setSelectedAssumption] = useState<'model' | 'enhanced' | 'high_risk'>('model');
  const [isPlaying, setIsPlaying] = useState(false);
  const [playbackSpeed, setPlaybackSpeed] = useState(1000);
  const [populationData, setPopulationData] = useState<any[]>([]);
  const [visitRates, setVisitRates] = useState<any>(null);
  const [genderDistribution, setGenderDistribution] = useState<any[]>([]);
  const [serviceVisits, setServiceVisits] = useState<ServiceVisits[]>([]);
  const [calculationDetails, setCalculationDetails] = useState<string>('');
  const [showFilters, setShowFilters] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  useEffect(() => {
    if (populationData.length > 0 && visitRates && genderDistribution.length > 0) {
      calculateServiceVisits();
    }
  }, [selectedYear, selectedRegion, selectedAssumption, populationData, visitRates, genderDistribution]);

  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (isPlaying) {
      interval = setInterval(() => {
        setSelectedYear(year => {
          if (year >= 2040) {
            setIsPlaying(false);
            return 2040;
          }
          return year + 1;
        });
      }, playbackSpeed);
    }
    return () => clearInterval(interval);
  }, [isPlaying, playbackSpeed]);

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
        const { data: popData } = await supabase
          .from('population_data')
          .select('*');

        const regionsWithData = regionsData.filter(region => 
          popData?.some(pd => pd.region_id === region.id)
        );

        setRegions(regionsWithData);
        setPopulationData(popData || []);
      }

      // Fetch visit rates
      const { data: ratesData, error: ratesError } = await supabase
        .from('visit_rates')
        .select('*');

      if (ratesError) {
        console.error('Error fetching visit rates:', ratesError);
        return;
      }

      // Transform visit rates data
      const transformedRates: Record<string, Record<string, Record<string, { male: number; female: number }>>> = {};
      
      SERVICES.forEach(service => {
        transformedRates[service] = {};
        AGE_GROUPS.forEach(ageGroup => {
          transformedRates[service][ageGroup] = {
            model: { male: 0, female: 0 },
            enhanced: { male: 0, female: 0 },
            high_risk: { male: 0, female: 0 }
          };
        });
      });

      ratesData?.forEach(rate => {
        if (transformedRates[rate.service] && 
            transformedRates[rate.service][rate.age_group]) {
          transformedRates[rate.service][rate.age_group][rate.assumption_type] = {
            male: rate.male_rate,
            female: rate.female_rate
          };
        }
      });

      setVisitRates(transformedRates);

      // Fetch gender distribution data
      const { data: genderData } = await supabase
        .from('gender_distribution_baseline')
        .select('male_data')
        .single();

      if (genderData?.male_data) {
        setGenderDistribution(genderData.male_data);
      }

    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  const getGenderDistribution = (ageGroup: string, year: number) => {
    const ageGroupData = genderDistribution.find(d => d.ageGroup === ageGroup);
    if (!ageGroupData) return { male: 0.5, female: 0.5 };

    const maleRatio = ageGroupData[year] || 0.5;
    return {
      male: maleRatio,
      female: 1 - maleRatio
    };
  };

  const calculateServiceVisits = () => {
    const visits: ServiceVisits[] = SERVICES.map(service => ({
      service,
      visits: 0,
      maleVisits: 0,
      femaleVisits: 0
    }));

    let details = `Calculation Details for ${selectedYear} (${selectedAssumption} assumptions):\n`;

    // Filter population data for selected region
    const relevantPopulation = populationData.filter(pd => 
      selectedRegion === 'all' || pd.region_id === selectedRegion
    );

    // Calculate total population for the year
    const totalPopulation = relevantPopulation.reduce((sum, pd) => {
      const yearValue = pd[`year_${selectedYear}`] || 0;
      const calculatedValue = (yearValue * pd.default_factor) / pd.divisor;
      return sum + calculatedValue;
    }, 0);

    details += `\nTotal Population (${selectedYear}): ${Math.round(totalPopulation)}\n`;

    // Process each population type separately
    relevantPopulation.forEach(pd => {
      const yearValue = pd[`year_${selectedYear}`] || 0;
      const calculatedValue = (yearValue * pd.default_factor) / pd.divisor;
      
      details += `\nPopulation Type: ${pd.population_type}\n`;
      details += `Base Population: ${yearValue}\n`;
      details += `Default Factor: ${pd.default_factor}\n`;
      details += `Divisor: ${pd.divisor}\n`;
      details += `Calculated Population: ${Math.round(calculatedValue)}\n`;

      if (pd.population_type === 'Staff') {
        // Staff population is only distributed across working age groups
        const workingAgeGroups = ['20 to 29', '30 to 44', '45 to 64'];
        const workingAgeDistribution = {
          '20 to 29': 0.27, // 27% of working population
          '30 to 44': 0.45, // 45% of working population
          '45 to 64': 0.28  // 28% of working population
        };

        AGE_GROUPS.forEach(ageGroup => {
          if (workingAgeGroups.includes(ageGroup)) {
            const ageGroupPopulation = calculatedValue * workingAgeDistribution[ageGroup as keyof typeof workingAgeDistribution];
            const { male: maleRatio, female: femaleRatio } = getGenderDistribution(ageGroup, selectedYear);
            
            const malePopulation = ageGroupPopulation * maleRatio;
            const femalePopulation = ageGroupPopulation * femaleRatio;

            details += `\n${ageGroup}:\n`;
            details += `  Population: ${Math.round(ageGroupPopulation)}\n`;
            details += `  Male: ${Math.round(malePopulation)} (${(maleRatio * 100).toFixed(1)}%)\n`;
            details += `  Female: ${Math.round(femalePopulation)} (${(femaleRatio * 100).toFixed(1)}%)\n`;

            // Calculate visits for each service
            SERVICES.forEach((service, index) => {
              const rates = visitRates[service]?.[ageGroup]?.[selectedAssumption];
              if (!rates) {
                console.warn(`No rates found for ${service} - ${ageGroup} - ${selectedAssumption}`);
                return;
              }

              const maleVisits = (malePopulation * rates.male) / 1000;
              const femaleVisits = (femalePopulation * rates.female) / 1000;

              visits[index].maleVisits += maleVisits;
              visits[index].femaleVisits += femaleVisits;
              visits[index].visits += maleVisits + femaleVisits;

              details += `  ${service}:\n`;
              details += `    Male Rate: ${rates.male}/1000, Visits: ${Math.round(maleVisits)}\n`;
              details += `    Female Rate: ${rates.female}/1000, Visits: ${Math.round(femaleVisits)}\n`;
            });
          } else {
            // Non-working age groups have zero population for staff
            details += `\n${ageGroup}:\n`;
            details += `  Population: 0 (Staff population not applicable for this age group)\n`;
          }
        });
      } else {
        // For other population types, use age group distribution
        AGE_GROUPS.forEach(ageGroup => {
          const { male: maleRatio, female: femaleRatio } = getGenderDistribution(ageGroup, selectedYear);
          
          // Calculate population for this age group
          const ageGroupPopulation = calculatedValue / AGE_GROUPS.length;
          const malePopulation = ageGroupPopulation * maleRatio;
          const femalePopulation = ageGroupPopulation * femaleRatio;

          details += `\n${ageGroup}:\n`;
          details += `  Population: ${Math.round(ageGroupPopulation)}\n`;
          details += `  Male: ${Math.round(malePopulation)} (${(maleRatio * 100).toFixed(1)}%)\n`;
          details += `  Female: ${Math.round(femalePopulation)} (${(femaleRatio * 100).toFixed(1)}%)\n`;

          // Calculate visits for each service
          SERVICES.forEach((service, index) => {
            const rates = visitRates[service]?.[ageGroup]?.[selectedAssumption];
            if (!rates) {
              console.warn(`No rates found for ${service} - ${ageGroup} - ${selectedAssumption}`);
              return;
            }

            const maleVisits = (malePopulation * rates.male) / 1000;
            const femaleVisits = (femalePopulation * rates.female) / 1000;

            visits[index].maleVisits += maleVisits;
            visits[index].femaleVisits += femaleVisits;
            visits[index].visits += maleVisits + femaleVisits;

            details += `  ${service}:\n`;
            details += `    Male Rate: ${rates.male}/1000, Visits: ${Math.round(maleVisits)}\n`;
            details += `    Female Rate: ${rates.female}/1000, Visits: ${Math.round(femaleVisits)}\n`;
          });
        });
      }
    });

    // Round all visit numbers
    visits.forEach(visit => {
      visit.maleVisits = Math.round(visit.maleVisits);
      visit.femaleVisits = Math.round(visit.femaleVisits);
      visit.visits = Math.round(visit.visits);
    });

    setServiceVisits(visits);
    setCalculationDetails(details);
  };

  const togglePlayback = () => {
    setIsPlaying(!isPlaying);
    if (!isPlaying && selectedYear === 2040) {
      setSelectedYear(2025);
    }
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
      {/* Filters Section */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">Analysis Filters</h2>
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="flex items-center space-x-2 text-gray-600 hover:text-emerald-600"
          >
            <Filter className="h-4 w-4" />
            <span>{showFilters ? 'Hide Filters' : 'Show Filters'}</span>
          </button>
        </div>

        {showFilters && (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Region</label>
              <select
                value={selectedRegion}
                onChange={(e) => setSelectedRegion(e.target.value)}
                className="w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
              >
                <option value="all">All Regions</option>
                {regions.map(region => (
                  <option key={region.id} value={region.id}>{region.name}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Year</label>
              <select
                value={selectedYear}
                onChange={(e) => setSelectedYear(parseInt(e.target.value))}
                className="w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
              >
                {Array.from({ length: 16 }, (_, i) => 2025 + i).map(year => (
                  <option key={year} value={year}>{year}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Calculation Model</label>
              <select
                value={selectedAssumption}
                onChange={(e) => setSelectedAssumption(e.target.value as 'model' | 'enhanced' | 'high_risk')}
                className="w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
              >
                <option value="model">Model</option>
                <option value="enhanced">Enhanced</option>
                <option value="high_risk">High Risk</option>
              </select>
            </div>
          </div>
        )}
      </div>

      <ServiceDemandAnalysis 
        regions={regions}
        selectedRegion={selectedRegion}
        selectedYear={selectedYear}
        selectedAssumption={selectedAssumption}
        isPlaying={isPlaying}
        playbackSpeed={playbackSpeed}
        serviceVisits={serviceVisits}
        onRegionChange={setSelectedRegion}
        onYearChange={setSelectedYear}
        onAssumptionChange={setSelectedAssumption}
        onPlaybackToggle={togglePlayback}
        onPlaybackSpeedChange={setPlaybackSpeed}
      />

      <ServiceVisitsBreakdown 
        regions={regions}
        selectedRegion={selectedRegion}
        selectedYear={selectedYear}
        serviceVisits={serviceVisits}
        calculationDetails={calculationDetails}
      />
    </div>
  );
}