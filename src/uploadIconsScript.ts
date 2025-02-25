import { uploadAllIcons } from './lib/uploadIcons';
import { checkIcons } from './lib/checkIcons';

async function main() {
  console.log('Starting icon upload process...');
  
  // First check current state
  console.log('\nChecking current state:');
  const beforeState = await checkIcons();
  console.log(`Files in storage before: ${beforeState.files.length}`);
  console.log(`Database records before: ${beforeState.databaseRecords?.length || 0}`);

  // Upload icons
  console.log('\nUploading icons...');
  await uploadAllIcons();

  // Check final state
  console.log('\nVerifying upload:');
  const afterState = await checkIcons();
  console.log(`Files in storage after: ${afterState.files.length}`);
  console.log(`Database records after: ${afterState.databaseRecords?.length || 0}`);

  // Verify all icons were uploaded
  const expectedIcons = 9; // Total number of icons we're uploading
  if (afterState.files.length === expectedIcons && 
      afterState.databaseRecords?.length === expectedIcons) {
    console.log('\nSuccess! All icons uploaded correctly.');
  } else {
    console.error('\nWarning: Not all icons were uploaded successfully.');
    console.error('Expected:', expectedIcons);
    console.error('Found in storage:', afterState.files.length);
    console.error('Found in database:', afterState.databaseRecords?.length);
  }

  // List all uploaded files
  console.log('\nUploaded files:');
  afterState.files.forEach(file => {
    console.log(`- ${file.name}`);
  });
}

main().catch(console.error);