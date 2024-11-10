/**
 * Simple wrapper around fetch API tailored for FiveM NUI
 * @param {string} eventName - The event name to target
 * @param {any} data - Data you wish to send
 * @returns Response from the server
 */
export async function fetchNui(eventName, data) {
    const options = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data),
    }
  
    const resourceName = window.GetParentResourceName 
        ? window.GetParentResourceName() 
        : 'desync-multichar'
  
    try {
        const resp = await fetch(`https://${resourceName}/${eventName}`, options)
        const responseText = await resp.text()
        
        if (!responseText) {
            return null // Return null instead of success=true
        }

        return JSON.parse(responseText)
    } catch (error) {
        console.error(`Error in fetchNui: ${error.message}`)
        throw error // Throw the error instead of returning success=true
    }
} 