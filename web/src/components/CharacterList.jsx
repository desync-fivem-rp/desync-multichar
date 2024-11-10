import { useState } from 'react'

function CharacterList({ characters, maxCharacters, onSelect, onDelete, onCreateNew }) {
  const [selectedChar, setSelectedChar] = useState(null)
  const [pendingDelete, setPendingDelete] = useState(null)

  const handleCharacterClick = (char) => {
    setSelectedChar(char)
  }

  const handleSpawnClick = () => {
    if (selectedChar) {
      onSelect(selectedChar.Identifier)
      setSelectedChar(null)
    }
  }

  const handleDeleteClick = () => {
    setPendingDelete(selectedChar)
  }

  const handleConfirmDelete = () => {
    if (pendingDelete) {
      onDelete(pendingDelete.Identifier)
      setPendingDelete(null)
      setSelectedChar(null)
    }
  }

  // Create array of slots based on maxCharacters
  const characterSlots = Array(maxCharacters).fill(null).map((_, index) => {
    return characters[index] || null
  })
  
  return (
    <div className="character-list">
      <h2>Character Selection</h2>
      
      <div className="character-list-items">
        {characterSlots.map((char, index) => (
          <div key={char?.Identifier || `empty-${index}`}>
            {char ? (
              // Existing character slot
              <div 
                className={`character-item ${selectedChar?.Identifier === char.Identifier ? 'selected' : ''}`}
                onClick={() => handleCharacterClick(char)}
              >
                <div className="character-name">
                  {char.FirstName} {char.LastName}
                </div>
              </div>
            ) : (
              // Empty slot
              <div 
                className="character-item empty"
                onClick={onCreateNew}
              >
                <div className="character-name empty">
                  Create New Character
                </div>
                <div className="slot-number">Slot {index + 1}</div>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Action buttons shown only when character is selected */}
      {selectedChar && (
        <div className="character-actions">
          <button
            onClick={handleSpawnClick}
            className="button button-primary"
          >
            Spawn Character
          </button>
          <button
            onClick={handleDeleteClick}
            className="button button-danger"
          >
            Delete Character
          </button>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {pendingDelete && (
        <div className="modal-overlay">
          <div className="modal-content">
            <h3>Confirm Delete</h3>
            <p>Are you sure you want to delete {pendingDelete.FirstName} {pendingDelete.LastName}?</p>
            <p className="warning-text">This action cannot be undone!</p>
            <div className="modal-buttons">
              <button 
                onClick={handleConfirmDelete}
                className="button button-danger"
              >
                Delete
              </button>
              <button 
                onClick={() => setPendingDelete(null)}
                className="button"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default CharacterList
