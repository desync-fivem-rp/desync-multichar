// Make sure to change resourceName here to match the name of this resource
const resourceName = 'desync-multichar'

// Just a wrapper for the JQ post method
const sendNuiEvent = (name, data, callback) => {
	$.post(`https://${resourceName}/${name}`, JSON.stringify(data), callback);
}

// --------------- Event listeners --------------- //

// Called any time SendNUIMessage() is called from client.lua, so this is where all of the magic happens
// Preferred design is to create functions for each thing you want to do and call these functions here to keep it clean.
// Examples below:
window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.debug && data.debug == true) {
        for (const [key, value] of Object.entries(data)) {
            console.log(key + ': ' + value);
        }
    }

	if (data.action == 'open') {
		OpenUI();
	}

    if (data.action == 'close') {
        CloseUI();
    }
});

// Called when this JS file loads into the HTML page (this will always occur on resource start)
window.addEventListener('load', () => {
    sendNuiEvent('loaded', {
        test: "This is some test data",
        anotherTest: "This is also some test data"
    }, (data) => {
        for (const [key, value] of Object.entries(data)) {
            console.log(key + ": " + value);
        }
    });
});

// Event listener that is called any time a key is released after being pressed
window.addEventListener('keyup', (key) => {
	if (key.code == 'Escape' && $('.wrapper').is(':visible')) {
		$('.wrapper').fadeOut(); // or replace with CloseUI() since we created a function for this below
		sendNuiEvent('close');
	};
});




// --------------- Functions --------------- //
function OpenUI() {
    $('.wrapper').fadeIn();
}

function CloseUI() {
    $('.wrapper').fadeOut();
}