import React from 'react';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Code, Database, Shield, Zap } from 'lucide-react';

export function ApiReference() {
  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      
      <main className="flex-grow p-8">
        <div className="max-w-4xl mx-auto">
          <div className="bg-white rounded-lg shadow-sm p-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-6">API Reference</h1>
            
            <div className="space-y-8">
              <section>
                <h2 className="text-2xl font-semibold text-gray-800 mb-4">Overview</h2>
                <p className="text-gray-600">
                  The NEOM ICD-10 Mapping API provides programmatic access to our mapping service. 
                  Use this API to integrate ICD-10 code mapping capabilities into your applications.
                </p>
              </section>

              <section>
                <h2 className="text-2xl font-semibold text-gray-800 mb-4">Authentication</h2>
                <div className="bg-emerald-50 rounded-lg p-6">
                  <div className="flex items-start">
                    <Shield className="h-6 w-6 text-emerald-600 mt-1" />
                    <div className="ml-4">
                      <h3 className="text-lg font-semibold text-gray-900">API Keys</h3>
                      <p className="mt-2 text-gray-600">
                        All API requests require authentication using an API key. Include your API key 
                        in the request headers:
                      </p>
                      <pre className="mt-4 bg-gray-800 text-gray-100 p-4 rounded-md overflow-x-auto">
                        <code>
                          Authorization: Bearer your-api-key
                        </code>
                      </pre>
                    </div>
                  </div>
                </div>
              </section>

              <section>
                <h2 className="text-2xl font-semibold text-gray-800 mb-4">Endpoints</h2>
                <div className="space-y-6">
                  <div className="border border-gray-200 rounded-lg p-6">
                    <div className="flex items-start">
                      <Code className="h-6 w-6 text-emerald-600 mt-1" />
                      <div className="ml-4">
                        <h3 className="text-lg font-semibold text-gray-900">Get Mapping</h3>
                        <p className="mt-2 text-gray-600">
                          Retrieve service mapping for a specific ICD-10 code.
                        </p>
                        <pre className="mt-4 bg-gray-800 text-gray-100 p-4 rounded-md overflow-x-auto">
                          <code>
                            GET /api/v1/mapping/{'{icd_code}'}
                          </code>
                        </pre>
                      </div>
                    </div>
                  </div>

                  <div className="border border-gray-200 rounded-lg p-6">
                    <div className="flex items-start">
                      <Database className="h-6 w-6 text-emerald-600 mt-1" />
                      <div className="ml-4">
                        <h3 className="text-lg font-semibold text-gray-900">Bulk Mapping</h3>
                        <p className="mt-2 text-gray-600">
                          Map multiple ICD-10 codes in a single request.
                        </p>
                        <pre className="mt-4 bg-gray-800 text-gray-100 p-4 rounded-md overflow-x-auto">
                          <code>
                            POST /api/v1/mapping/bulk
                          </code>
                        </pre>
                      </div>
                    </div>
                  </div>

                  <div className="border border-gray-200 rounded-lg p-6">
                    <div className="flex items-start">
                      <Zap className="h-6 w-6 text-emerald-600 mt-1" />
                      <div className="ml-4">
                        <h3 className="text-lg font-semibold text-gray-900">Service Lookup</h3>
                        <p className="mt-2 text-gray-600">
                          Get available services for a care setting.
                        </p>
                        <pre className="mt-4 bg-gray-800 text-gray-100 p-4 rounded-md overflow-x-auto">
                          <code>
                            GET /api/v1/services/{'{care_setting}'}
                          </code>
                        </pre>
                      </div>
                    </div>
                  </div>
                </div>
              </section>

              <section>
                <h2 className="text-2xl font-semibold text-gray-800 mb-4">Rate Limits</h2>
                <div className="bg-emerald-50 rounded-lg p-6">
                  <ul className="space-y-2 text-gray-600">
                    <li>Free tier: 1,000 requests per day</li>
                    <li>Professional tier: 10,000 requests per day</li>
                    <li>Enterprise tier: Custom limits</li>
                  </ul>
                </div>
              </section>
            </div>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}