import { useState, useEffect } from 'react'
import { fetchNui } from '../utils/fetchNui'
import CreateCharacter from '../components/CreateCharacter'

function CharacterSelect() {
  const [visible, setVisible] = useState(false)
  const [characters, setCharacters] = useState([])
  const [isCreating, setIsCreating] = useState(false)
  
  useEffect(() => {
    // console.log('CharacterSelect mounted')
    
    const handleMessage = (event) => {
      const data = event.data
      // console.log('Received message:', data)
      
      if (data.type === 'ui' && data.action === 'showCharacterSelect') {
        // console.log('Setting visible to:', data.status)
        setVisible(data.status)

      }

      if (data.type === 'setCharacters') {
        // console.log('Setting characters:', data.characters)
        setCharacters(data.characters || [])
      }
    }

    window.addEventListener('message', handleMessage)
    return () => window.removeEventListener('message', handleMessage)
  }, [])

  if (!visible) {
    return null
  }
    

  return (
    <div className="character-select" style={{
      position: 'fixed',
      top: 0,
      left: 0,
      width: '100%',
      height: '100%',
      backgroundColor: 'rgba(0, 0, 0, 0.95)',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      zIndex: 9999,
      color: 'white',
      userSelect: 'none',
      pointerEvents: 'auto'
    }}>
      <h1 style={{color: 'white', fontSize: '32px', marginBottom: '20px'}}>
        Character Selection
      </h1>
      
      {isCreating ? (
        <CreateCharacter onCancel={() => setIsCreating(false)} />
      ) : (
        <>
          <div className="character-list" style={{margin: '20px 0'}}>
            {characters.length === 0 ? (
              <p style={{color: 'white', fontSize: '24px'}}>No characters found</p>
            ) : (
              characters.map(char => (
                <div 
                  key={char.Identifier} 
                  className="character-card" 
                  style={{
                    padding: '20px',
                    backgroundColor: 'rgba(255, 255, 255, 0.1)',
                    borderRadius: '8px',
                    color: 'white',
                    cursor: 'pointer'
                  }}
                  onClick={() => {
                    console.log('Selected character:', char.Identifier)
                    console.log("=======================================")
                    fetchNui('selectCharacter', { characterId: char.Identifier })
                  }}
                >
                  {char.FirstName} {char.LastName}
                </div>
              ))
            )}
          </div>
          <div style={{display: 'flex', gap: '10px'}}>
            <button style={{
              padding: '10px 20px',
              backgroundColor: '#4a90e2',
              border: 'none',
              borderRadius: '4px',
              color: 'white',
              cursor: 'pointer',
              fontSize: '16px'
            }} onClick={() => setIsCreating(!isCreating)}>
              {isCreating ? 'Cancel' : 'Create New Character'}
            </button>
            <button style={{
              padding: '10px 20px',
              backgroundColor: '#e24a4a',
              border: 'none',
              borderRadius: '4px',
              color: 'white',
              cursor: 'pointer',
              fontSize: '16px'
            }} onClick={() => {
              // console.log('Close button clicked')
              setVisible(false)
              fetchNui('desync-multichar:hideui')
            }}>Close</button>
          </div>
        </>
      )}
    </div>
  )
}

export default CharacterSelect 