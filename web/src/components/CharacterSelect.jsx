import { useState, useEffect } from 'react'
import { fetchNui } from '../utils/fetchNui'
import CharacterList from './CharacterList'
import CreateCharacter from './CreateCharacter'
import './CharacterSelect.css'

function CharacterSelect() {
  const [characters, setCharacters] = useState([])
  const [view, setView] = useState('list') // 'list' or 'create'
  const [visible, setVisible] = useState(false)
  const [maxCharacters, setMaxCharacters] = useState(6) // Default value
  const [selectedCharacter, setSelectedCharacter] = useState(null)
  const [cameraMode, setCameraMode] = useState('overview') // 'overview' or 'focused'
  
  const refreshCharacters = async () => {
    try {
      const result = await fetchNui('getCharacters')
      setCharacters(Array.isArray(result) ? result : [])
    } catch (error) {
      console.error('[CharacterSelect] Error refreshing characters:', error)
    }
  }

  useEffect(() => {
    // console.log('[CharacterSelect] Component mounted')
    
    const handleMessage = (event) => {
      const data = event.data
      // console.log('[CharacterSelect] Received message:', data)
      
      if (data.type === 'ui') {
        // console.log('[CharacterSelect] UI visibility changed:', data.status)
        setVisible(data.status)
        if (!data.status) {
          // Clean up when hiding UI
          setSelectedCharacter(null)
          setView('list')
          fetchNui('desync-multichar:hideui')
        }
        if (data.maxCharacters) {
          // console.log('[CharacterSelect] Max characters set to:', data.maxCharacters)
          setMaxCharacters(data.maxCharacters)
        }
      } else if (data.type === 'setCharacters') {
        // console.log('[CharacterSelect] Setting characters:', data.characters)
        setCharacters(Array.isArray(data.characters) ? data.characters : [])
      }
    }

    // Initial character fetch
    refreshCharacters()
    
    window.addEventListener('message', handleMessage)
    // console.log('[CharacterSelect] Message event listener attached')
    
    return () => {
      // console.log('[CharacterSelect] Component unmounting, removing event listener')
      window.removeEventListener('message', handleMessage)
      // Clean up when component unmounts
      fetchNui('desync-multichar:hideui')
    }
  }, [])

  // Log when visibility changes
  useEffect(() => {
    // console.log('[CharacterSelect] Visibility changed:', visible)
  }, [visible])

  // Prevent right-click menu when rotating camera
  const handleContextMenu = (e) => {
    e.preventDefault()
  }

  useEffect(() => {
    document.addEventListener('contextmenu', handleContextMenu)
    return () => {
      document.removeEventListener('contextmenu', handleContextMenu)
    }
  }, [])

  if (!visible) {
    return null
  }

  const handleCharacterSelect = async (charId) => {
    setSelectedCharacter(charId)
    setCameraMode('focused')
    // Send NUI message to move camera
    await fetchNui('focusCharacter', { characterId: charId })
  }

  const handleSpawnConfirm = async () => {
    if (!selectedCharacter) {
      return
    }
    
    try {
        // Just tell the client to switch to spawn selection
        await fetchNui('switchToSpawnSelect', { characterId: selectedCharacter })
        setVisible(false)
    } catch (error) {
        // console.error('[CharacterSelect] Error switching to spawn selection:', error)
    }
  }
  

  const handleCharacterDelete = async (charId) => {
    try {
      await fetchNui('deleteCharacter', { characterId: charId })
      await refreshCharacters() // Refresh the list after deletion
    } catch (error) {
      // console.error('Error deleting character:', error)
    }
  }

  const handleCharacterCreated = async () => {
    // console.log('Character created, refreshing list')
    await refreshCharacters() // Refresh the list to show new character
    setView('list') // Switch back to list view
  }

  return (
    <div className="character-select-container">
      {view === 'list' ? (
        <div className="character-select-bottom">
          {selectedCharacter && (
            <div className="character-actions">
              <button 
                className="spawn-button"
                onClick={handleSpawnConfirm}
              >
                Play Character
              </button>
              <button 
                className="delete-button"
                onClick={() => handleCharacterDelete(selectedCharacter)}
              >
                Delete Character
              </button>
            </div>
          )}
          <div className="character-list">
            {[...Array(maxCharacters)].map((_, index) => {
                const char = characters[index];
                if (char) {
                    return (
                        <div 
                            key={char.Identifier}
                            className={`character-card ${selectedCharacter === char.Identifier ? 'selected' : ''}`}
                            onClick={() => handleCharacterSelect(char.Identifier)}
                        >
                            <h3>{char.FirstName} {char.LastName}</h3>
                            <div className="character-info">
                                {/* <p>Cash: ${char.Money || 0}</p> */}
                            </div>
                        </div>
                    );
                } else {
                    return (
                        <div 
                            key={`empty-${index}`}
                            className="character-card empty"
                            onClick={() => setView('create')}
                        >
                            <span>Create Character</span>
                        </div>
                    );
                }
            })}
          </div>
        </div>
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