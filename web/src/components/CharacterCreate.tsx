import { useState, useEffect } from 'react'
import { fetchNui } from '../utils/fetchNui'
import '../styles/CharacterCreate.css'

interface Props {
    onCancel: () => void;
}

const CharacterCreate: React.FC<Props> = ({onCancel}) => {
    const [error, setError] = useState('');
    const [formData, setFormData] = useState<FormData>();

    interface FormData {
        firstName?: string,
        lastName?: string,
        gender?: string,
        dateOfBirth?: string
    };

    useEffect(() => {
        fetchNui('focusOnNewCharacter', {});
      }, []); // empty dependency array

    // console.log('CharacterCreate rendered');
    // fetchNui('focusOnNewCharacter', {})

    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        setError('');

        if (!formData?.firstName || !formData?.lastName)
        {
            setError("Please fill in a first and last name")
            return
        }

        if (!formData?.gender)
        {
            setError("Please select a gender")
            return
        }

        if (!formData?.dateOfBirth)
        {
            setError("Please select a date of birth")
            return
        }

        try {
            await fetchNui("createCharacter", {
                firstName: formData?.firstName,
                lastName: formData?.lastName,
                gender: formData?.gender,
                dateOfBirth: formData?.dateOfBirth
            });
        } catch (error) {
            console.log(error);
        }
    };

    const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setError('');

        const {name, value } = e.target

        setFormData((prevFormData) => ({
            ...prevFormData,
            [name]: value,
        }));
    };

    const handleSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
        setError('');

        const {name, value } = e.target

        setFormData((prevFormData) => ({
            ...prevFormData,
            [name]: value,
        }));
    };

    const handleCancelClick = () => {
        fetchNui('focusOnCharacterOverview', {});
        onCancel();
    }

    // const onCancel = () => {
    //     console.log("Canceled");
    //     setShowForm(false);   
    // }

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
            name="firstName"
            placeholder="First Name"
            value={formData?.firstName}
            onChange={handleInputChange}
            className="input-field"
            />
    
            <input
            type="text"
            name="lastName"
            placeholder="Last Name"
            value={formData?.lastName}
            onChange={handleInputChange}
            className="input-field"
            />
    
            <select
            name="gender"
            value={formData?.gender}
            onChange={handleSelectChange}
            className="input-field"
            >
            <option value="">Select Gender</option>
            <option value="male">Male</option>
            <option value="female">Female</option>
            <option value="non-binary">Non-binary</option>
            </select>
    
            <input
            type="date"
            name="dateOfBirth"
            value={formData?.dateOfBirth}
            onChange={handleInputChange}
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
                onClick={handleCancelClick}
                className="button button-danger"
            >
                Cancel
            </button>
            </div>
        </form>
        </div>
      );
};

export default CharacterCreate;