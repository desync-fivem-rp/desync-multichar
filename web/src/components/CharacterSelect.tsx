import { useState, useEffect } from 'react'
import { fetchNui } from '../utils/fetchNui';
import { useNuiEvent } from '../hooks/useNuiEvent';
import '../styles/CharacterSelect.css';
import CharacterCreate from './CharacterCreate';

const CharacterSelect: React.FC = () => {
    const [maxCharacters, setMaxCharacters] = useState<number>(0);
    const [characters, setCharacters] = useState<Character[]>([]);
    const [selectedCharacter, setSelectedCharacter] = useState<number | null>(null);
    const [showCreateCharacter, setShowCreateCharacter] = useState(false);
    const [attemptingToDeleteCharacter, setAttemptingToDeleteCharacter] = useState(false);

    interface Character {
        charId: number;
        userId: number;
        stateId: number;
        firstName: string;
        lastName: string;
        fullName: string | null;
        gender: string;
        dateOfBirth: Date;
        phoneNumber: string | null;
        lastPlayed: Date;
        isDead: boolean;
        x: number | null;
        y: number | null;
        z: number | null;
        heading: number | null;
        health: number | null;
        armour: number | null;
        statuses: Record<string, any>;
        deleted: Date | null;
      };

    interface initialData {
        maxCharacters: number,
        characters: Character[]
    };

    useNuiEvent<initialData>('init', (data) => {
        setMaxCharacters(data.maxCharacters);
        setCharacters(data.characters);
    });

    const handleCharacterSelect = async (charId: number) => {
        setSelectedCharacter(charId);
        await fetchNui('focusOnCharacter', {charId: charId})
    };

    const handleCharacterPlay = async () => {
        // refresh characters? maybe just call Init() again?

        try {
            await fetchNui('characterSelected', {charId: selectedCharacter})
            setSelectedCharacter(null);
        } catch (error) {
            console.log(error)
        }
    };

    const handleCharacterDelete = async (selectedCharacter: number) => {
        // console.log("deleting character: " + selectedCharacter)

        try {
            await fetchNui('deleteCharacter', {charId: selectedCharacter})
            setAttemptingToDeleteCharacter(false);
            setSelectedCharacter(null);

            // refresh characters? maybe just call Init() again?
        } catch (error) {
            console.log(error)
        }
    };

    const handleCharacterDeleteConfirmation = () => {
        // console.log("Attempting to delete character");
        setAttemptingToDeleteCharacter(true);
    };

    const handleCancel = () => {
        setShowCreateCharacter(false);
    }

    useEffect(() => {
        // console.log("Attempting to delete character: " + attemptingToDeleteCharacter)
    }, [attemptingToDeleteCharacter])

    useEffect(() => {
        // console.log("Selected character: " + selectedCharacter)
    }, [selectedCharacter])

    return (
        <div className="character-select-container">
            {showCreateCharacter ? (
                <CharacterCreate onCancel={handleCancel}/>
            ): (
                <div className="character-select-bottom">
                    {attemptingToDeleteCharacter && selectedCharacter &&(
                        <div className="confirmation-dialog">
                            <p>Are you sure you want to delete your character?</p>
                            <button className="cancel-button" onClick={() => setAttemptingToDeleteCharacter(false)}>No</button>
                            <button className="delete-button" onClick={() => handleCharacterDelete(selectedCharacter)}>Yes</button>
                      </div>
                    )}
                    {selectedCharacter && (
                        <div className="character-actions">
                            <button className="play-button" onClick={handleCharacterPlay}>
                                Play Character
                            </button>
                            <button className="delete-button" onClick = {handleCharacterDeleteConfirmation}> 
                                {/* handleCharacterDelete(selectedCharacter) */}
                                Delete Character
                            </button>
                        </div>
                    )}
                    <div className="character-list">
                        {(() => {
                            const characterCards = [];
                            for (let i = 0; i < maxCharacters; i++) {
                            const char = characters[i];
                            if (char) {
                                characterCards.push(
                                <div
                                    key={char.charId}
                                    className={`character-card ${selectedCharacter === char.charId ? 'selected' : ''}`}
                                    onClick={() => handleCharacterSelect(char.charId)}
                                >
                                    <h3>{char.firstName} {char.lastName}</h3>
                                    <div className="character-info">
                                    {/* <p>Cash: ${char.Money || 0}</p> */}
                                    </div>
                                </div>
                                );
                            } else {
                                characterCards.push(
                                <div
                                    key={`empty-${i}`}
                                    className="character-card"
                                    onClick={() => setShowCreateCharacter(true)}
                                >
                                    <span>Create Character</span>
                                </div>
                                );
                            }
                            }
                            return characterCards;
                        })()}
                    </div>
                </div>
            )}            
        </div>
    )
}

export default CharacterSelect;