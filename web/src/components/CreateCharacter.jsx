import { useState, useEffect } from 'react'
import { fetchNui } from '../utils/fetchNui'

function CreateCharacter({ onCancel, onCreated, characters, maxCharacters }) {
  const [formData, setFormData] = useState({
    firstname: '',
    lastname: '',
    dob: ''
  })
  const [error, setError] = useState(null)

  useEffect(() => {
    const handleMessage = (event) => {
      const data = event.data
      // console.log('Received message in CreateCharacter:', data)
      
      if (data.type === 'createCharacterResponse') {
        if (data.success) {
          // console.log('Character created successfully')
          onCreated()
        } else {
          // console.error('Character creation failed:', data.error)
          setError(data.error || 'Failed to create character')
        }
      }
    }

    window.addEventListener('message', handleMessage)
    return () => window.removeEventListener('message', handleMessage)
  }, [onCreated])

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError(null)
    
    if (characters.length >= maxCharacters) {
      setError(`Maximum number of characters (${maxCharacters}) reached`)
      return
    }

    if (!formData.firstname || !formData.lastname) {
      setError('Please fill in first name and last name')
      return
    }

    try {
      // console.log('Submitting character creation:', formData)
      await fetchNui('createCharacter', {
        firstname: formData.firstname,
        lastname: formData.lastname
      })
      
      // console.log('Character creation request sent')
      onCancel()
    } catch (error) {
      // console.error('Error creating character:', error)
      setError('Failed to submit character creation request')
    }
  }

  const handleChange = (e) => {
    setError(null) // Clear error when user starts typing
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    })
  }

  return (
    <div className="create-character">
      <h2>Create New Character</h2>
      
      {error && (
        <div className="error-message">
          {error}
        </div>
      )}
      
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          name="firstname"
          placeholder="First Name"
          value={formData.firstname}
          onChange={handleChange}
          className="input-field"
        />
        
        <input
          type="text"
          name="lastname"
          placeholder="Last Name"
          value={formData.lastname}
          onChange={handleChange}
          className="input-field"
        />
        
        <input
          type="date"
          name="dob"
          value={formData.dob}
          onChange={handleChange}
          className="input-field"
        />

        <div className="button-container">
          <button
            type="submit"
            className="button button-primary"
          >
            Create
          </button>
          <button
            type="button"
            onClick={onCancel}
            className="button button-danger"
          >
            Cancel
          </button>
        </div>
      </form>
    </div>
  )
}

export default CreateCharacter
