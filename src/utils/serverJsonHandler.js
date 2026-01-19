import { importDiagramFromJson } from "./exportImportJson";

let fileHandle = null;

export async function loadDataJsonFromServer() {
  try {
    // Try to fetch data.json from the app base URL (works on /editor too)
    const response = await fetch(`${import.meta.env.BASE_URL}data.json`);
    
    if (response.ok) {
      const jsonText = await response.text();
      
      // Create a mock File object for the import function
      const blob = new Blob([jsonText], { type: 'application/json' });
      const file = new File([blob], 'data.json', { type: 'application/json' });
      
      const processedData = await importDiagramFromJson(file);
      return processedData;
    }
  } catch (error) {
    console.log("No data.json found on server or failed to load:", error);
  }
  
  return null;
}

export async function saveDataJsonToServer(diagramData) {
  try {
    // First try to use File System Access API if available
    if ('showSaveFilePicker' in window) {
      if (!fileHandle) {
        try {
          fileHandle = await window.showSaveFilePicker({
            suggestedName: 'data.json',
            types: [{
              description: 'JSON files',
              accept: { 'application/json': ['.json'] },
            }],
          });
        } catch (error) {
          // User cancelled or not supported, fallback to download
          console.log("File System Access not available, using download fallback");
          return saveDataJsonAsDownload(diagramData);
        }
      }
      
      const writable = await fileHandle.createWritable();
      const jsonStr = JSON.stringify(diagramData, null, 2);
      await writable.write(jsonStr);
      await writable.close();
      return true;
    } else {
      // Fallback to download method
      return saveDataJsonAsDownload(diagramData);
    }
  } catch (error) {
    console.error("Failed to save data.json:", error);
    return false;
  }
}

function saveDataJsonAsDownload(diagramData) {
  try {
    const jsonStr = JSON.stringify(diagramData, null, 2);
    const blob = new Blob([jsonStr], { type: "application/json" });
    
    // Create download link and trigger download
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = "data.json";
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    return true;
  } catch (error) {
    console.error("Failed to download data.json:", error);
    return false;
  }
}

export function resetFileHandle() {
  fileHandle = null;
}
