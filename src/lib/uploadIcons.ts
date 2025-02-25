import { supabase } from './supabase';

const icons = [
  {
    name: 'Location Pin Blue',
    url: 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/map-pin.svg',
    filename: 'location-pin-blue.svg',
    type: 'both'
  },
  {
    name: 'Location Pin Green', 
    url: 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/navigation.svg',
    filename: 'location-pin-green.svg',
    type: 'both'
  },
  {
    name: 'Location Mark Blue',
    url: 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/locate.svg',
    filename: 'location-mark-blue.svg',
    type: 'both'
  },
  {
    name: 'Location Mark Green',
    url: 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/target.svg',
    filename: 'location-mark-green.svg',
    type: 'both'
  },
  {
    name: 'Hospital Blue',
    url: 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/building-2.svg',
    filename: 'hospital-blue.svg',
    type: 'both'
  },
  {
    name: 'Hospital Green',
    url: 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/hotel.svg',
    filename: 'hospital-green.svg',
    type: 'both'
  },
  {
    name: 'Medical Blue',
    url: 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/stethoscope.svg',
    filename: 'medical-blue.svg',
    type: 'both'
  },
  {
    name: 'Medical Green',
    url: 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/heart-pulse.svg',
    filename: 'medical-green.svg',
    type: 'both'
  },
  {
    name: 'Emergency Red',
    url: 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/plus-circle.svg',
    filename: 'emergency-red.svg',
    type: 'both'
  }
];

export async function uploadAllIcons() {
  // First clear existing icons from storage
  const { data: existingFiles } = await supabase.storage
    .from('icons')
    .list();

  if (existingFiles && existingFiles.length > 0) {
    const filesToRemove = existingFiles.map(file => file.name);
    await supabase.storage
      .from('icons')
      .remove(filesToRemove);
  }

  // Clear existing map_icons records
  await supabase
    .from('map_icons')
    .delete()
    .neq('id', '00000000-0000-0000-0000-000000000000'); // Delete all records

  for (const icon of icons) {
    try {
      // Fetch SVG content
      const response = await fetch(icon.url);
      const svgContent = await response.text();
      
      // Convert SVG content to Blob
      const blob = new Blob([svgContent], { type: 'image/svg+xml' });
      const file = new File([blob], icon.filename, { type: 'image/svg+xml' });

      // Upload to Supabase Storage
      const { data, error: uploadError } = await supabase.storage
        .from('icons')
        .upload(icon.filename, file, {
          cacheControl: '3600',
          upsert: true
        });

      if (uploadError) {
        console.error(`Error uploading ${icon.name}:`, uploadError);
        continue;
      }

      // Get the public URL
      const { data: { publicUrl } } = supabase.storage
        .from('icons')
        .getPublicUrl(icon.filename);

      // Insert record into map_icons table
      const { error: dbError } = await supabase
        .from('map_icons')
        .insert([{
          name: icon.name,
          url: publicUrl,
          icon_type: icon.type,
          storage_path: icon.filename,
          mime_type: 'image/svg+xml',
          is_active: true
        }]);

      if (dbError) {
        console.error(`Error inserting ${icon.name} into database:`, dbError);
        continue;
      }

      console.log(`Successfully uploaded and registered ${icon.name}`);
    } catch (error) {
      console.error(`Error processing ${icon.name}:`, error);
    }
  }

  // Update settings with default icons
  try {
    // Get IDs for default icons
    const { data: locationPinBlue } = await supabase
      .from('map_icons')
      .select('id')
      .eq('name', 'Location Pin Blue')
      .single();

    const { data: locationMarkBlue } = await supabase
      .from('map_icons')
      .select('id')
      .eq('name', 'Location Mark Blue')
      .single();

    // Update region settings
    if (locationPinBlue) {
      await supabase
        .from('region_settings')
        .update({ icon_id: locationPinBlue.id })
        .is('icon_id', null);
    }

    // Update sub-region settings
    if (locationMarkBlue) {
      await supabase
        .from('sub_region_settings')
        .update({ icon_id: locationMarkBlue.id })
        .is('icon_id', null);
    }
  } catch (error) {
    console.error('Error updating settings with default icons:', error);
  }
}