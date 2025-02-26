import { useState, useEffect } from "react";
import { Header } from "../components/Header";
import { Footer } from "../components/Footer";
import { AssetsForm } from "../components/assets/AssetsForm";
import { AssetsTable } from "../components/assets/AssetsTable";
import { AssetsMap } from "../components/assets/AssetsMap";
import { Building2 } from "lucide-react";
import { api } from "../services/api";

interface Asset {
  id: string;
  region_id: string;
  asset_id: string;
  name: string;
  type: string;
  owner: string;
  archetype: string;
  population_types: string[];
  start_date: string;
  end_date: string | null;
  latitude: number;
  longitude: number;
  gfa: number;
  status: string;
}

export function Assets() {
  const [selectedAsset, setSelectedAsset] = useState<Asset | null>(null);
  const [assets, setAssets] = useState<Asset[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAssets();
  }, []);

  const fetchAssets = async () => {
    try {
      setLoading(true);
      const data = await api.get("/assets");

      setAssets(data || []);
    } catch (err) {
      console.error("Error fetching assets:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleEdit = (asset: Asset) => {
    setSelectedAsset(asset);
    // Scroll to form
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      <main className="flex-grow p-8">
        <div className="max-w-7xl mx-auto space-y-8">
          {/* Overview Section */}
          <div className="bg-white rounded-lg shadow-sm p-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-6">
              Healthcare Assets
            </h1>
            <p className="text-gray-600 mb-8">
              Track and manage healthcare facilities and infrastructure across
              regions. Monitor asset status, capacity, and distribution to
              ensure optimal healthcare service delivery and resource
              utilization.
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="bg-emerald-50 rounded-lg p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-3">
                  Asset Management
                </h2>
                <p className="text-gray-600">
                  Maintain comprehensive records of healthcare facilities
                  including hospitals, clinics, and specialized care centers.
                </p>
              </div>

              <div className="bg-emerald-50 rounded-lg p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-3">
                  Infrastructure Planning
                </h2>
                <p className="text-gray-600">
                  Plan and monitor healthcare infrastructure development to
                  ensure balanced distribution and adequate coverage.
                </p>
              </div>
            </div>
          </div>

          {/* Assets Management */}
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center space-x-2 mb-6">
              <Building2 className="h-6 w-6 text-emerald-600" />
              <h2 className="text-2xl font-bold text-gray-900">
                Assets Management
              </h2>
            </div>

            <div className="space-y-8">
              <AssetsForm initialAsset={selectedAsset} />
              <AssetsTable onEdit={handleEdit} />
              <AssetsMap assets={assets} loading={loading} />
            </div>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}
