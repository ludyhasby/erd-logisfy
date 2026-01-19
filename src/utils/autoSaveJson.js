import { exportDiagramToJson, importDiagramFromJson } from "./exportImportJson";

const DATA_JSON_FILENAME = "data.json";

export function saveToJsonFile(diagramData) {
  try {
    const jsonStr = JSON.stringify(diagramData, null, 2);
    const blob = new Blob([jsonStr], { type: "application/json" });
    
    // Create download link and trigger download
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = DATA_JSON_FILENAME;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    return true;
  } catch (error) {
    console.error("Failed to save to data.json:", error);
    return false;
  }
}

export async function loadFromJsonFile() {
  return new Promise((resolve) => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json,application/json';
    
    input.onchange = (e) => {
      const file = e.target.files[0];
      if (file && file.name === DATA_JSON_FILENAME) {
        const reader = new FileReader();
        reader.onload = async (e) => {
          try {
            const data = JSON.parse(e.target.result);
            const processedData = await importDiagramFromJson(file);
            resolve(processedData);
          } catch (error) {
            console.error("Failed to load data.json:", error);
            resolve(null);
          }
        };
        reader.onerror = () => {
          console.error("Failed to read data.json file");
          resolve(null);
        };
        reader.readAsText(file);
      } else {
        resolve(null);
      }
    };
    
    input.oncancel = () => resolve(null);
    
    // Trigger file dialog
    input.click();
  });
}

export function checkForDataJsonFile() {
  // Check if there's a data.json file in the current directory
  // This is a simplified check - in a real app, you might want to use File System Access API
  return new Promise((resolve) => {
    // For now, we'll prompt the user to select data.json if it exists
    // In a real implementation, you could use the File System Access API to check automatically
    resolve(false);
  });
}
