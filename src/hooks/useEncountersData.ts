import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { EncounterStats, SystemOfCareStats, OptimizationData } from '../types/encounters';

export function useEncountersData() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [encounterStats, setEncounterStats] = useState<EncounterStats[]>([]);
  const [systemDistribution, setSystemDistribution] = useState<SystemOfCareStats[]>([]);
  const [optimizationData, setOptimizationData] = useState<OptimizationData[]>([]);
  const [retrying, setRetrying] = useState(false);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Fetch all required data in parallel
      const [statsResult, systemResult, optimizationResult, topIcdResult] = await Promise.all([
        supabase.from('encounters_statistics').select('*'),
        supabase.from('system_of_care_analysis').select('*'),
        supabase.from('care_setting_optimization_data').select('*'),
        supabase.from('icd_code_analysis')
          .select('*')
          .order('total_encounters', { ascending: false })
          .limit(5)
      ]);

      if (statsResult.error) throw statsResult.error;
      if (systemResult.error) throw systemResult.error;
      if (optimizationResult.error) throw optimizationResult.error;
      if (topIcdResult.error) throw topIcdResult.error;

      // Transform the data to include system distribution and top ICD codes
      const transformedStats = statsResult.data.map(stat => {
        const systemDistributions = systemResult.data.reduce((acc, system) => {
          const percentage = system.care_setting_percentages?.[stat.care_setting];
          if (percentage !== undefined) {
            acc[system.system_of_care] = percentage;
          }
          return acc;
        }, {} as Record<string, number>);

        return {
          ...stat,
          system_distribution: systemDistributions,
          top_icd_codes: topIcdResult.data.map(icd => ({
            icd_family_code: icd.icd_family_code,
            description: icd.description || 'No description available',
            encounters: icd.total_encounters,
            percentage: (icd.total_encounters / stat.encounter_count) * 100
          }))
        };
      });

      setEncounterStats(transformedStats);
      setSystemDistribution(systemResult.data);
      setOptimizationData(optimizationResult.data);
    } catch (err) {
      console.error('Error fetching data:', err);
      setError(
        err instanceof Error 
          ? err.message 
          : 'Failed to load encounter statistics. Please try again.'
      );
    } finally {
      setLoading(false);
      setRetrying(false);
    }
  };

  const handleRetry = () => {
    setRetrying(true);
    fetchData();
  };

  useEffect(() => {
    fetchData();
  }, []);

  return {
    loading,
    error,
    encounterStats,
    systemDistribution,
    optimizationData,
    retrying,
    handleRetry
  };
}