import React, { useEffect, useState } from 'react'

// Simple galleries panel: list, load, delete
export default function GalleriesPanel() {
  const [galleries, setGalleries] = useState([])

  useEffect(() => {
    window.gallery?.listGalleries().then(setGalleries).catch(() => setGalleries([]))
  }, [])

  async function loadGallery(id) {
    const manifest = await window.gallery.loadGallery(id)
    // This is a placeholder: you should wire this to your app's renderer state
    console.log('Loaded gallery:', manifest)
  }

  async function deleteGallery(id) {
    if (!confirm('Delete this gallery?')) return
    await window.gallery.deleteGallery(id)
    // refresh list
    const fresh = await window.gallery.listGalleries()
    setGalleries(fresh)
  }

  return (
    <div className="galleries-panel">
      <h3>Galleries</h3>
      {galleries.length === 0 && <div>No galleries saved yet.</div>}
      <ul>
        {galleries.map((g) => (
          <li key={g.id}>
            <span>{g.name}</span>
            <span style={{ marginLeft: 8, color: '#666' }}>{new Date(g.createdAt).toLocaleString()}</span>
            <button onClick={() => loadGallery(g.id)} style={{ marginLeft: 8 }}>Load</button>
            <button onClick={() => deleteGallery(g.id)} style={{ marginLeft: 4 }}>Delete</button>
            <span style={{ marginLeft: 8 }}>Images: {g.counts.images}, Audios: {g.counts.audios}</span>
          </li>
        ))}
      </ul>
    </div>
  )
}
