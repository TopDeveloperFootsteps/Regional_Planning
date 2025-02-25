import { supabase } from './supabase';

interface UploadResult {
  success: boolean;
  url?: string;
  error?: string;
}

export async function validateFile(file: File): Promise<string | null> {
  const validTypes = ['image/svg+xml', 'image/png'];
  const maxSize = 1024 * 1024; // 1MB

  if (!validTypes.includes(file.type)) {
    return 'Only SVG and PNG files are allowed';
  }

  if (file.size > maxSize) {
    return 'File size must be less than 1MB';
  }

  return null;
}

export async function uploadIcon(file: File, iconType: 'region' | 'sub_region' | 'both'): Promise<UploadResult> {
  try {
    // Validate file
    const validationError = await validateFile(file);
    if (validationError) {
      return { success: false, error: validationError };
    }

    const timestamp = Date.now();
    const cleanName = file.name.replace(/[^a-zA-Z0-9.-]/g, '_');
    const fileName = `${timestamp}-${cleanName}`;

    // Upload to storage
    const { data, error: uploadError } = await supabase.storage
      .from('icons')
      .upload(fileName, file, {
        cacheControl: '3600',
        contentType: file.type,
        upsert: false
      });

    if (uploadError) {
      throw new Error(uploadError.message);
    }

    if (!data?.path) {
      throw new Error('Upload succeeded but no path was returned');
    }

    // Get public URL
    const { data: { publicUrl } } = supabase.storage
      .from('icons')
      .getPublicUrl(data.path);

    if (!publicUrl) {
      throw new Error('Failed to get public URL for uploaded file');
    }

    // Insert record into map_icons table
    const { error: dbError } = await supabase
      .from('map_icons')
      .insert([{
        name: file.name.replace(/\.[^/.]+$/, ''),
        url: publicUrl,
        storage_path: data.path,
        mime_type: file.type,
        icon_type: iconType,
        is_active: true
      }]);

    if (dbError) {
      // Clean up uploaded file if database insert fails
      await supabase.storage
        .from('icons')
        .remove([data.path])
        .catch(console.error);

      throw new Error('Failed to save icon information to database');
    }

    return { success: true, url: publicUrl };
  } catch (error: any) {
    console.error('Upload error:', error);
    return {
      success: false,
      error: error.message || 'Failed to upload icon'
    };
  }
}