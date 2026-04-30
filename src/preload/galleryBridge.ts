// Exposes gallery storage IPC surface to the renderer
import { contextBridge, ipcRenderer } from 'electron'

const api = {
  saveGallery: (payload: { name: string; user: { id: string; name: string }; imagePaths: string[]; audioPaths: string[] }) =>
    ipcRenderer.invoke('gallery:saveGallery', payload),
  listGalleries: () => ipcRenderer.invoke('gallery:listGalleries'),
  loadGallery: (id: string) => ipcRenderer.invoke('gallery:loadGallery', id),
  deleteGallery: (id: string) => ipcRenderer.invoke('gallery:deleteGallery', id),
}

// Surface under window.gallery in renderer processes
contextBridge.exposeInMainWorld('gallery', api)
