import React from 'react';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { QuickLinks } from '../components/QuickLinks';
import { TableList } from '../components/TableList';
import { MappingInterface } from '../components/MappingInterface';

export function ServicesMapping() {
  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      
      <main className="flex-grow p-8">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
            <div className="lg:col-span-3 space-y-8">
              <div className="bg-white rounded-lg shadow-sm p-8">
                <h1 className="text-3xl font-bold text-gray-900 mb-6">Services Mapping</h1>
                <p className="text-gray-600 mb-8">
                  Map healthcare services to ICD-10 codes across different care settings to ensure 
                  optimal service delivery and resource allocation.
                </p>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="bg-emerald-50 rounded-lg p-6">
                    <h2 className="text-xl font-semibold text-gray-900 mb-3">Care Settings</h2>
                    <p className="text-gray-600">
                      Map ICD-10 codes across multiple healthcare settings including hospitals, 
                      clinics, and specialized care facilities.
                    </p>
                  </div>

                  <div className="bg-emerald-50 rounded-lg p-6">
                    <h2 className="text-xl font-semibold text-gray-900 mb-3">Service Mapping</h2>
                    <p className="text-gray-600">
                      Get accurate service recommendations based on ICD-10 codes and care settings.
                    </p>
                  </div>
                </div>
              </div>

              <MappingInterface />
            </div>

            <div className="lg:col-span-1 space-y-6">
              <QuickLinks />
              <TableList />
            </div>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}