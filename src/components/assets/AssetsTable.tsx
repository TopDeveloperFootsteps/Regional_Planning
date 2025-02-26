import { useState, useEffect } from "react";
import { Edit2, ToggleLeft, ToggleRight } from "lucide-react";
import { api } from "../../services/api";

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
  is_active?: boolean;
}

interface AssetsTableProps {
  onEdit: (asset: Asset) => void;
}

export function AssetsTable({ onEdit }: AssetsTableProps) {
  const [assets, setAssets] = useState<Asset[]>([]);
  const [showInactive, setShowInactive] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchAssets();
  }, [showInactive]);

  const fetchAssets = async () => {
    try {
      setLoading(true);
      setError(null);

      const data = await api.get("/assets/assetsTable"); // Update to your backend API
      // Filter assets based on status
      const filteredAssets = data.filter((asset) =>
        showInactive ? true : asset.status !== "Closed"
      );

      setAssets(filteredAssets);
    } catch (err) {
      console.error("Error fetching assets:", err);
      setError("Failed to load assets");
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  if (error) {
    return <div className="text-red-600 p-4 text-center">{error}</div>;
  }

  return (
    <div className="space-y-4">
      {/* Table Controls */}
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold text-gray-900">Assets List</h3>
        <button
          onClick={() => setShowInactive(!showInactive)}
          className="flex items-center space-x-2 text-gray-600 hover:text-emerald-600"
        >
          {showInactive ? (
            <ToggleRight className="h-5 w-5" />
          ) : (
            <ToggleLeft className="h-5 w-5" />
          )}
          <span>Show Inactive Assets</span>
        </button>
      </div>

      {/* Assets Table */}
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Asset ID
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Name
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Type
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Owner
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Archetype
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {assets.map((asset) => (
              <tr
                key={asset.id}
                className={asset.status === "Closed" ? "bg-gray-50" : ""}
              >
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {asset.asset_id}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {asset.name}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {asset.type}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {asset.owner}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {asset.archetype}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span
                    className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                      asset.status === "Operational"
                        ? "bg-green-100 text-green-800"
                        : asset.status === "Partially Operational"
                        ? "bg-yellow-100 text-yellow-800"
                        : asset.status === "Closed"
                        ? "bg-red-100 text-red-800"
                        : asset.status === "Not Started"
                        ? "bg-gray-100 text-gray-800"
                        : "bg-blue-100 text-blue-800"
                    }`}
                  >
                    {asset.status}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <button
                    onClick={() => onEdit(asset)}
                    className="text-emerald-600 hover:text-emerald-900"
                  >
                    <Edit2 className="h-4 w-4" />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {assets.length === 0 && (
        <div className="text-center py-8 text-gray-500">No assets found</div>
      )}
    </div>
  );
}
