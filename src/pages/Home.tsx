import React from 'react';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Link } from 'react-router-dom';
import { 
  Map, 
  Building2, 
  Activity, 
  FileText, 
  Settings,
  Users,
  Calculator,
  BarChart,
  Network,
  BarChart2
} from 'lucide-react';

export function Home() {
  const features = [
    {
      title: 'Services Mapping',
      description: 'Map healthcare services to ICD-10 codes across different care settings',
      icon: <Activity className="h-6 w-6" />,
      link: '/services'
    },
    {
      title: 'Care Settings',
      description: 'Analyze and optimize healthcare delivery across different care settings',
      icon: <Network className="h-6 w-6" />,
      link: '/encounters'
    },
    {
      title: 'Regions',
      description: 'Manage and visualize healthcare regions and sub-regions',
      icon: <Map className="h-6 w-6" />,
      link: '/regions'
    },
    {
      title: 'Assets',
      description: 'Track and manage healthcare facilities and infrastructure',
      icon: <Building2 className="h-6 w-6" />,
      link: '/assets'
    },
    {
      title: 'Population Analysis',
      description: 'Project and analyze population segments for healthcare planning',
      icon: <Users className="h-6 w-6" />,
      link: '/population'
    },
    {
      title: 'Capacity Planning',
      description: 'Calculate and optimize healthcare facility capacity needs',
      icon: <Calculator className="h-6 w-6" />,
      link: '/capacity'
    },
    {
      title: 'Service Distribution',
      description: 'Optimize healthcare service distribution across regions',
      icon: <BarChart className="h-6 w-6" />,
      link: '/distribution'
    },
    {
      title: 'Demand Forecasting',
      description: 'Project future healthcare demand based on population trends',
      icon: <BarChart2 className="h-6 w-6" />,
      link: '/forecasting'
    }
  ];

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      <main className="flex-grow p-8">
        <div className="max-w-7xl mx-auto">
          {/* Hero Section */}
          <div className="text-center mb-12">
            <h1 className="text-4xl font-bold text-gray-900 mb-4">
              Regional Planning Models
            </h1>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Comprehensive healthcare infrastructure planning system for optimizing facility distribution 
              and service accessibility across regions
            </p>
          </div>

          {/* Features Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
            {features.map((feature) => (
              <Link
                key={feature.title}
                to={feature.link}
                className="bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow group"
              >
                <div className="flex items-center space-x-4">
                  <div className="flex-shrink-0 w-12 h-12 bg-emerald-50 rounded-lg flex items-center justify-center group-hover:bg-emerald-100 transition-colors">
                    <div className="text-emerald-600">
                      {feature.icon}
                    </div>
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900 group-hover:text-emerald-600 transition-colors">
                      {feature.title}
                    </h3>
                    <p className="text-sm text-gray-600 mt-1">
                      {feature.description}
                    </p>
                  </div>
                </div>
              </Link>
            ))}
          </div>

          {/* Key Features Section */}
          <div className="bg-white rounded-lg shadow-sm p-8 mb-12">
            <h2 className="text-2xl font-semibold text-gray-900 mb-6">Key Features</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              <div className="space-y-2">
                <h3 className="text-lg font-medium text-gray-900">Population Analysis</h3>
                <p className="text-gray-600">
                  Project and analyze population segments including residents, staff, visitors, and 
                  construction workers to inform healthcare planning.
                </p>
              </div>
              <div className="space-y-2">
                <h3 className="text-lg font-medium text-gray-900">Asset Management</h3>
                <p className="text-gray-600">
                  Track and manage healthcare facilities with detailed information about type, 
                  ownership, and operational status.
                </p>
              </div>
              <div className="space-y-2">
                <h3 className="text-lg font-medium text-gray-900">Service Mapping</h3>
                <p className="text-gray-600">
                  Map healthcare services to ICD-10 codes and optimize service distribution across 
                  different care settings.
                </p>
              </div>
            </div>
          </div>

          {/* Quick Actions */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="bg-white rounded-lg shadow-sm p-6">
              <div className="flex items-center space-x-4">
                <FileText className="h-6 w-6 text-emerald-600" />
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Documentation</h3>
                  <p className="text-sm text-gray-600">Access guides and documentation</p>
                </div>
              </div>
            </div>
            <div className="bg-white rounded-lg shadow-sm p-6">
              <div className="flex items-center space-x-4">
                <Settings className="h-6 w-6 text-emerald-600" />
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Settings</h3>
                  <p className="text-sm text-gray-600">Configure system preferences</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}