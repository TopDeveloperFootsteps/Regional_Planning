import React, { useState } from 'react';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { PopulationAnalysis } from './PopulationAnalysis';
import { PopulationEntry } from './PopulationEntry';
import { Users } from 'lucide-react';

export function Population() {
  const [activeTab, setActiveTab] = useState<'analysis' | 'entry'>('analysis');

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      <main className="flex-grow p-8">
        <div className="max-w-7xl mx-auto space-y-8">
          {/* Overview Section */}
          <div className="bg-white rounded-lg shadow-sm p-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-6">Population Management</h1>
            <p className="text-gray-600 mb-8">
              Comprehensive population management system for analyzing demographics, trends, and managing population data 
              across different segments and regions.
            </p>

            {/* Tabs */}
            <div className="border-b border-gray-200">
              <nav className="-mb-px flex space-x-8">
                <button
                  onClick={() => setActiveTab('analysis')}
                  className={`${
                    activeTab === 'analysis'
                      ? 'border-emerald-500 text-emerald-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  } whitespace-nowrap pb-4 px-1 border-b-2 font-medium text-sm`}
                >
                  Population Analysis
                </button>
                <button
                  onClick={() => setActiveTab('entry')}
                  className={`${
                    activeTab === 'entry'
                      ? 'border-emerald-500 text-emerald-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  } whitespace-nowrap pb-4 px-1 border-b-2 font-medium text-sm`}
                >
                  Population Entry
                </button>
              </nav>
            </div>
          </div>

          {/* Tab Content */}
          {activeTab === 'analysis' ? <PopulationAnalysis /> : <PopulationEntry />}
        </div>
      </main>
      <Footer />
    </div>
  );
}