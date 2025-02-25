import { checkIcons } from './lib/checkIcons';

checkIcons().then((result) => {
  console.log('\nStorage Files:');
  console.log(result.files);
  
  console.log('\nDatabase Records:');
  console.log(result.databaseRecords);
  
  if (result.error) {
    console.error('\nError:', result.error);
  }
  
  console.log('\nSummary:');
  console.log(`Files in storage: ${result.files.length}`);
  console.log(`Records in database: ${result.databaseRecords?.length || 0}`);
});