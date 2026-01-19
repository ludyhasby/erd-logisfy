import { saveAs } from "file-saver";
import { databases } from "../data/databases";
import { nanoid } from "nanoid";

export function exportDiagramToJson(diagramData, filename = "diagram") {
  const exportData = {
    version: "1.0",
    exported: new Date().toISOString(),
    ...diagramData
  };
  
  const jsonStr = JSON.stringify(exportData, null, 2);
  const blob = new Blob([jsonStr], { type: "application/json" });
  saveAs(blob, `${filename}.json`);
}

export function importDiagramFromJson(jsonFile) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    
    reader.onload = (e) => {
      try {
        const data = JSON.parse(e.target.result);
        
        // Validate required fields
        if (!data.tables || !Array.isArray(data.tables)) {
          throw new Error("Invalid diagram format: missing tables array");
        }
        
        // Ensure all tables have IDs
        const processedTables = data.tables.map(table => ({
          ...table,
          id: table.id || nanoid(),
          fields: table.fields.map(field => ({
            ...field,
            id: field.id || nanoid()
          }))
        }));
        
        // Ensure all relationships have IDs
        const processedRelationships = (data.relationships || []).map(rel => ({
          ...rel,
          id: rel.id || nanoid()
        }));
        
        // Process types if exists
        const processedTypes = (data.types || []).map(type => ({
          ...type,
          id: type.id || nanoid(),
          fields: (type.fields || []).map(field => ({
            ...field,
            id: field.id || nanoid()
          }))
        }));
        
        // Process enums if exists
        const processedEnums = (data.enums || []).map(enumItem => ({
          ...enumItem,
          id: enumItem.id || nanoid()
        }));
        
        const processedData = {
          ...data,
          tables: processedTables,
          relationships: processedRelationships,
          types: processedTypes,
          enums: processedEnums
        };
        
        resolve(processedData);
      } catch (error) {
        reject(new Error(`Failed to parse JSON file: ${error.message}`));
      }
    };
    
    reader.onerror = () => {
      reject(new Error("Failed to read file"));
    };
    
    reader.readAsText(jsonFile);
  });
}

export function createJsonFileInput() {
  return new Promise((resolve, reject) => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json,application/json';
    
    input.onchange = (e) => {
      const file = e.target.files[0];
      if (file) {
        resolve(file);
      } else {
        reject(new Error("No file selected"));
      }
    };
    
    input.click();
  });
}
