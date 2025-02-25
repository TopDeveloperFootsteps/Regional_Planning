import React, { useState } from 'react';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Calculator, Activity, Stethoscope, Building2, FileBarChart, Settings } from 'lucide-react';
import { PrimaryOpVisits } from '../components/assumptions/PrimaryOpVisits';
import { SpecialistOpVisits } from '../components/assumptions/SpecialistOpVisits';
import { UrgentEmergencyVisits } from '../components/assumptions/UrgentEmergencyVisits';
import { InpatientAdmissions } from '../components/assumptions/InpatientAdmissions';
import { MajorDiagnosticTreatment } from '../components/assumptions/MajorDiagnosticTreatment';
import { OtherInpatientAssumptions } from '../components/assumptions/OtherInpatientAssumptions';
import { OperationalAssumptions } from '../components/assumptions/OperationalAssumptions';

type Tab = {
  id: string;
  name: string;
  icon: React.ReactNode;
  component: React.ReactNode;
};

export function Assumptions() {
  const [activeTab, setActiveTab] = useState('primary-op');

  const tabs: Tab[] = [
    {
      id: 'primary-op',
      name: 'Primary OP Visits Rate',
      icon: <Calculator className="h-5 w-5" />,
      component: <PrimaryOpVisits />
    },
    {
      id: 'specialist-op',
      name: 'Specialist OP Visits Rate',
      icon: <Stethoscope className="h-5 w-5" />,
      component: <SpecialistOpVisits />
    },
    {
      id: 'urgent-emergency',
      name: 'Urgent Emergency Visit Rates',
      icon: <Activity className="h-5 w-5" />,
      component: <UrgentEmergencyVisits />
    },
    {
      id: 'inpatient',
      name: 'Inpatient Admissions Rate',
      icon: <Building2 className="h-5 w-5" />,
      component: <InpatientAdmissions />
    },
    {
      id: 'diagnostic',
      name: 'Major Diag&Treatment Rates',
      icon: <FileBarChart className="h-5 w-5" />,
      component: <MajorDiagnosticTreatment />
    },
    {
      id: 'other',
      name: 'Other Inpatient Assumptions',
      icon: <Settings className="h-5 w-5" />,
      component: <OtherInpatientAssumptions />
    },
    {
      id: 'operational',
      name: 'Operational Assumptions',
      icon: <Settings className="h-5 w-5" />,
      component: <OperationalAssumptions />
    }
  ];

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      <main className="flex-grow p-8">
        <div className="max-w-7xl mx-auto space-y-8">
          {/* Overview Section */}
          <div className="bg-white rounded-lg shadow-sm p-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-6">Healthcare Assumptions</h1>
            <p className="text-gray-600 mb-8">
              Configure and manage healthcare service assumptions across different care settings. These assumptions help in 
              planning and optimizing healthcare service delivery based on population needs and service utilization patterns.
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="bg-emerald-50 rounded-lg p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-3">Service Planning</h2>
                <p className="text-gray-600">
                  Define service utilization rates and assumptions to project future healthcare needs and capacity requirements.
                </p>
              </div>

              <div className="bg-emerald-50 rounded-lg p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-3">Resource Optimization</h2>
                <p className="text-gray-600">
                  Set baseline assumptions for different service types to optimize resource allocation and service delivery.
                </p>
              </div>
            </div>
          </div>

          {/* Tabs Navigation */}
          <div className="border-b border-gray-200 overflow-x-auto">
            <nav className="-mb-px flex space-x-8">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`
                    whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm
                    ${activeTab === tab.id
                      ? 'border-emerald-500 text-emerald-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                    }
                    flex items-center space-x-2
                  `}
                >
                  {tab.icon}
                  <span>{tab.name}</span>
                </button>
              ))}
            </nav>
          </div>

          {/* Tab Content */}
          <div className="mt-6">
            {tabs.find(tab => tab.id === activeTab)?.component}
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}