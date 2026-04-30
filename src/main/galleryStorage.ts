import { promises as fs } from 'fs'
import path from 'path'
import { app } from 'electron'
import { randomUUID } from 'crypto'

type UserInfo = { id: string; name: string }
type GalleryAssets = { images: string[]; audios: string[] }
type GalleryManifest = {
  id: string
  name: string
  user: UserInfo
  createdAt: string
  counts: { images: number; audios: number }
  assets: GalleryAssets
}

export default class GalleryStorage {
  private root: string

  constructor() {
    // Store galleries under userData/galleries
    this.root = path.join(app.getPath('userData'), 'galleries')
  }

  private async ensureDir(p: string) {
    await fs.mkdir(p, { recursive: true })
  }

  async saveGallery(data: {
    name: string
    user: UserInfo
    imagePaths: string[]
    audioPaths: string[]
  }): Promise<GalleryManifest> {
    const { name, user, imagePaths, audioPaths } = data
    await this.ensureDir(this.root)
    const id = (randomUUID && randomUUID()) || Date.now().toString()
    const dir = path.join(this.root, id)
    await this.ensureDir(dir)
    const imagesDir = path.join(dir, 'images')
    const audiosDir = path.join(dir, 'audios')
    await this.ensureDir(imagesDir)
    await this.ensureDir(audiosDir)

    const assetsImages: string[] = []
    for (const p of imagePaths) {
      const filename = path.basename(p)
      const dest = path.join(imagesDir, filename)
      try {
        await fs.copyFile(p, dest)
      } catch {
        // If copy fails, try to write an empty placeholder to avoid breaking flow
        await fs.writeFile(dest, '')
      }
      assetsImages.push(path.relative(dir, dest).split(path.sep).join('/'))
    }

    const assetsAudios: string[] = []
    for (const p of audioPaths) {
      const filename = path.basename(p)
      const dest = path.join(audiosDir, filename)
      try {
        await fs.copyFile(p, dest)
      } catch {
        await fs.writeFile(dest, '')
      }
      assetsAudios.push(path.relative(dir, dest).split(path.sep).join('/'))
    }

    const manifest: GalleryManifest = {
      id,
      name,
      user,
      createdAt: new Date().toISOString(),
      counts: { images: assetsImages.length, audios: assetsAudios.length },
      assets: { images: assetsImages, audios: assetsAudios },
    }

    const manifestPath = path.join(dir, 'gallery.json')
    await fs.writeFile(manifestPath, JSON.stringify(manifest, null, 2), 'utf8')
    return manifest
  }

  async listGalleries(): Promise<Array<{ id: string; name: string; createdAt: string; counts: { images: number; audios: number } }>> {
    const results: Array<{ id: string; name: string; createdAt: string; counts: { images: number; audios: number } }> = []
    try {
      const entries = await fs.readdir(this.root, { withFileTypes: true })
      for (const d of entries) {
        if (d.isDirectory()) {
          const manifestPath = path.join(this.root, d.name, 'gallery.json')
          try {
            const raw = await fs.readFile(manifestPath, 'utf8')
            const m = JSON.parse(raw) as GalleryManifest
            results.push({ id: d.name, name: m.name, createdAt: m.createdAt, counts: m.counts })
          } catch {
            // ignore invalid/malformed gallery entries
          }
        }
      }
    } catch {
      // no galleries yet
    }
    // sort newest first
    results.sort((a, b) => (new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()))
    return results
  }

  async loadGallery(id: string): Promise<GalleryManifest> {
    const manifestPath = path.join(this.root, id, 'gallery.json')
    const raw = await fs.readFile(manifestPath, 'utf8')
    return JSON.parse(raw) as GalleryManifest
  }

  async deleteGallery(id: string): Promise<void> {
    const dir = path.join(this.root, id)
    // Use fs.rm with recursive delete when available
    if ((fs as any).rm) {
      await (fs as any).rm(dir, { recursive: true, force: true })
    } else {
      // Fallback for older Node: attempt to unlink recursively
      const rimraf = require('rimraf')
      await new Promise((resolve, reject) => rimraf(dir, (err: any) => (err ? reject(err) : resolve(null))))
    }
  }
}
