/**
 * Simple wrapper around fetch API tailored for FiveM NUI
 * @param {string} eventName - The event name to target
 * @param {any} data - Data you wish to send
 * @returns Response from the server
 */
export async function fetchNui(eventName, data) {
    const resourceName = window.GetParentResourceName 
        ? window.GetParentResourceName() 
        : 'desync-multichar'

    // console.log(`[fetchNui] Sending request to ${resourceName}/${eventName}`, data)
    
    const options = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data),
    }
  
    try {
        // console.log(`[fetchNui] Fetching from https://${resourceName}/${eventName}`)
        const resp = await fetch(`https://${resourceName}/${eventName}`, options)
        // console.log('[fetchNui] Raw response:', resp)
        
        const responseText = await resp.text()
        // console.log('[fetchNui] Response text:', responseText)
        
        if (!responseText) {
            // console.log('[fetchNui] Empty response, returning null')
            return null
        }

        const parsedResponse = JSON.parse(responseText)
        // console.log('[fetchNui] Parsed response:', parsedResponse)
        return parsedResponse
    } catch (error) {
        // console.error(`[fetchNui] Error:`, error)
        throw error
    }
} 