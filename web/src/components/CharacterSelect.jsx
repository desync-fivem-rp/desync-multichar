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
    console.log('[CharacterSelect] Attempting to refresh characters')
    try {
      const response = await fetchNui('getCharacters')
      console.log('[CharacterSelect] getCharacters response:', response)
    } catch (error) {
      console.error('[CharacterSelect] Error refreshing characters:', error)
    }
  }

  useEffect(() => {
    console.log('[CharacterSelect] Component mounted')
    
    const handleMessage = (event) => {
      const data = event.data
      console.log('[CharacterSelect] Received message:', data)
      
      if (data.type === 'ui') {
        console.log('[CharacterSelect] UI visibility changed:', data.status)
        setVisible(data.status)
        if (data.maxCharacters) {
          console.log('[CharacterSelect] Max characters set to:', data.maxCharacters)
          setMaxCharacters(data.maxCharacters)
        }
      } else if (data.type === 'setCharacters') {
        console.log('[CharacterSelect] Setting characters:', data.characters)
        setCharacters(Array.isArray(data.characters) ? data.characters : [])
      }
    }

    // Initial character fetch
    refreshCharacters()
    
    window.addEventListener('message', handleMessage)
    console.log('[CharacterSelect] Message event listener attached')
    
    return () => {
      console.log('[CharacterSelect] Component unmounting, removing event listener')
      window.removeEventListener('message', handleMessage)
    }
  }, [])

  // Log when visibility changes
  useEffect(() => {
    console.log('[CharacterSelect] Visibility changed:', visible)
  }, [visible])

  if (!visible) {
    return null
  }

  const handleCharacterSelect = async (charId) => {
    try {
        console.log('[CharacterSelect] Attempting to spawn character:', charId)
        const response = await fetchNui('spawnCharacter', { characterId: charId })
        console.log('[CharacterSelect] Spawn response:', response)
        
        if (response && response.success) {
            console.log('[CharacterSelect] Character spawn successful')
            setVisible(false)
        } else {
            console.error('[CharacterSelect] Character spawn failed:', response)
        }
    } catch (error) {
        console.error('[CharacterSelect] Error spawning character:', error)
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
    <div className="character-select-container">
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
    </div>
  )
}

export default CharacterSelect