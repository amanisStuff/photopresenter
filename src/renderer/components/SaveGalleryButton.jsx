import React from 'react'

// This button saves the currently selected media as a new Gallery.
// The app should expose current media paths to window.__CURRENT_GALLERY_IMAGES__ and __CURRENT_GALLERY_AUDIOS__ if available.
export default function SaveGalleryButton({ onSaved }) {
  async function onClick() {
    const name = prompt('Name this gallery (optional):') || 'Untitled Gallery'
    const imagePaths = (window.__CURRENT_GALLERY_IMAGES__ || [])
    const audioPaths = (window.__CURRENT_GALLERY_AUDIOS__ || [])
    const payload = {
      name,
      user: { id: 'local-user', name: 'Local User' },
      imagePaths,
      audioPaths,
    }
    try {
      const manifest = await window.gallery.saveGallery(payload)
      onSaved?.(manifest)
    } catch (e) {
      console.error('Failed to save gallery', e)
    }
  }

  return (
    <button onClick={onClick}>Save Gallery</button>
  )
}
