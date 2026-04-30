import { useEffect, useState } from 'react'

export function useGalleries() {
  const [galleries, setGalleries] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let mounted = true
    window.gallery?.listGalleries().then((list) => {
      if (mounted) {
        setGalleries(list)
        setLoading(false)
      }
    }).catch(() => {
      if (mounted) {
        setGalleries([])
        setLoading(false)
      }
    })
    return () => { mounted = false }
  }, [])

  return { galleries, loading, refresh: () => {
    window.gallery?.listGalleries().then(setGalleries).catch(() => {})
  } }
}
