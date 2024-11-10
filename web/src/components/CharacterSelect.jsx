import { useState, useEffect } from 'react'
import { fetchNui } from '../utils/fetchNui'
import CharacterList from './CharacterList'
import CreateCharacter from './CreateCharacter'

function CharacterSelect() {
  const [characters, setCharacters] = useState([])
  const [view, setView] = useState('list') // 'list' or 'create'
  const [visible, setVisible] = useState(false)
  const [maxCharacters, setMaxCharacters] = useState(6) // Default value
  
  const refreshCharacters = async () => {
    console.log('Refreshing characters')
    try {
      await fetchNui('getCharacters')
    } catch (error) {
      console.error('Error refreshing characters:', error)
    }
  }

  useEffect(() => {
    const handleMessage = (event) => {
      const data = event.data
      console.log('Received message:', data)
      
      if (data.type === 'ui') {
        setVisible(data.status)
        if (data.maxCharacters) {
          setMaxCharacters(data.maxCharacters)
        }
      } else if (data.type === 'setCharacters') {
        console.log('Setting characters:', data.characters)
        setCharacters(Array.isArray(data.characters) ? data.characters : [])
      }
    }

    // Initial character fetch
    refreshCharacters()
    
    window.addEventListener('message', handleMessage)
    return () => window.removeEventListener('message', handleMessage)
  }, [])

  // Don't render anything if not visible
  if (!visible) return null

  const handleCharacterSelect = async (charId) => {
    try {
      console.log('Spawning character:', charId)
      await fetchNui('spawnCharacter', { characterId: charId })
      setVisible(false) // Hide the UI after character spawn
    } catch (error) {
      console.error('Error spawning character:', error)
    }
  }

  const handleCharacterDelete = async (charId) => {
    try {
      await fetchNui('deleteCharacter', { characterId: charId })
      await refreshCharacters() // Refresh the list after deletion
    } catch (error) {
      console.error('Error deleting character:', error)
    }
  }

  const handleCharacterCreated = async () => {
    console.log('Character created, refreshing list')
    await refreshCharacters() // Refresh the list to show new character
    setView('list') // Switch back to list view
  }

  return (
    <div className="character-select">
      {view === 'list' ? (
        <CharacterList 
          characters={characters}
          maxCharacters={maxCharacters}
          onSelect={handleCharacterSelect}
          onDelete={handleCharacterDelete}
          onCreateNew={() => setView('create')}
        />
      ) : (
        <CreateCharacter 
          onCancel={() => setView('list')}
          onCreated={handleCharacterCreated}
          characters={characters}
          maxCharacters={maxCharacters}
        />
      )}
    </div>
  )
}

export default CharacterSelect