import React from 'react';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { FileText, BookOpen, Code, CheckCircle } from 'lucide-react';

export function Documentation() {
  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      
      <main className="flex-grow p-8">
        <div className="max-w-4xl mx-auto">
          <div className="bg-white rounded-lg shadow-sm p-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-6">Documentation</h1>
            
            <div className="space-y-8">
              <section>
                <h2 className="text-2xl font-semibold text-gray-800 mb-4">Getting Started</h2>
                <div className="prose prose-emerald max-w-none">
                  <p className="text-gray-600">
                    The NEOM ICD-10 Mapping System is designed to help healthcare providers efficiently map ICD-10 codes 
                    to appropriate services across different care settings. This documentation will guide you through the 
                    system's features and functionality.
                  </p>
                </div>
              </section>

              <section className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="bg-emerald-50 rounded-lg p-6">
                  <div className="flex items-start">
                    <FileText className="h-6 w-6 text-emerald-600 mt-1" />
                    <div className="ml-4">
                      <h3 className="text-lg font-semibold text-gray-900">Basic Usage</h3>
                      <p className="mt-2 text-gray-600">Learn how to use the basic features of the mapping system.</p>
                    </div>
                  </div>
                </div>

                <div className="bg-emerald-50 rounded-lg p-6">
                  <div className="flex items-start">
                    <BookOpen className="h-6 w-6 text-emerald-600 mt-1" />
                    <div className="ml-4">
                      <h3 className="text-lg font-semibold text-gray-900">Advanced Features</h3>
                      <p className="mt-2 text-gray-600">Explore advanced mapping capabilities and bulk operations.</p>
                    </div>
                  </div>
                </div>

                <div className="bg-emerald-50 rounded-lg p-6">
                  <div className="flex items-start">
                    <Code className="h-6 w-6 text-emerald-600 mt-1" />
                    <div className="ml-4">
                      <h3 className="text-lg font-semibold text-gray-900">API Integration</h3>
                      <p className="mt-2 text-gray-600">Integrate the mapping system with your existing applications.</p>
                    </div>
                  </div>
                </div>

                <div className="bg-emerald-50 rounded-lg p-6">
                  <div className="flex items-start">
                    <CheckCircle className="h-6 w-6 text-emerald-600 mt-1" />
                    <div className="ml-4">
                      <h3 className="text-lg font-semibold text-gray-900">Best Practices</h3>
                      <p className="mt-2 text-gray-600">Learn recommended practices for optimal system usage.</p>
                    </div>
                  </div>
                </div>
              </section>

              <section>
                <h2 className="text-2xl font-semibold text-gray-800 mb-4">Key Features</h2>
                <ul className="space-y-4">
                  <li className="flex items-start">
                    <CheckCircle className="h-5 w-5 text-emerald-600 mt-1" />
                    <span className="ml-3 text-gray-600">Comprehensive ICD-10 code mapping across multiple care settings</span>
                  </li>
                  <li className="flex items-start">
                    <CheckCircle className="h-5 w-5 text-emerald-600 mt-1" />
                    <span className="ml-3 text-gray-600">Bulk upload capabilities for efficient processing</span>
                  </li>
                  <li className="flex items-start">
                    <CheckCircle className="h-5 w-5 text-emerald-600 mt-1" />
                    <span className="ml-3 text-gray-600">Confidence scoring for mapping accuracy</span>
                  </li>
                  <li className="flex items-start">
                    <CheckCircle className="h-5 w-5 text-emerald-600 mt-1" />
                    <span className="ml-3 text-gray-600">Detailed mapping logic explanations</span>
                  </li>
                </ul>
              </section>
            </div>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}