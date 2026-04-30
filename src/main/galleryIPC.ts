import { ipcMain } from 'electron'
import GalleryStorage from './galleryStorage'

const storage = new GalleryStorage()

ipcMain.handle('gallery:saveGallery', async (event, payload) => {
  return storage.saveGallery(payload)
})

ipcMain.handle('gallery:listGalleries', async () => {
  return storage.listGalleries()
})

ipcMain.handle('gallery:loadGallery', async (event, id) => {
  return storage.loadGallery(id)
})

ipcMain.handle('gallery:deleteGallery', async (event, id) => {
  return storage.deleteGallery(id)
})
