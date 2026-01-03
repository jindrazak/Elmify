const program = require('./elm/Main.elm');

// Initialize Elm application
const app = program.Elm.Main.init({
    flags: {}
});

// ============================================================================
// PKCE Helper Functions (crypto operations that must be in JavaScript)
// ============================================================================

/**
 * Generate a random string for the code verifier.
 * Must be between 43-128 characters, using unreserved URI characters.
 */
function generateCodeVerifier() {
    const array = new Uint8Array(64);
    crypto.getRandomValues(array);
    return base64UrlEncode(array);
}

/**
 * Generate the code challenge from the verifier using SHA-256.
 */
async function generateCodeChallenge(verifier) {
    const encoder = new TextEncoder();
    const data = encoder.encode(verifier);
    const digest = await crypto.subtle.digest('SHA-256', data);
    return base64UrlEncode(new Uint8Array(digest));
}

/**
 * Base64 URL encode (RFC 4648 §5).
 * Converts bytes to base64, then replaces + with -, / with _, and removes =.
 */
function base64UrlEncode(bytes) {
    let binary = '';
    for (let i = 0; i < bytes.length; i++) {
        binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary)
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=+$/, '');
}

// ============================================================================
// Elm Port Subscriptions
// ============================================================================

/**
 * Generate PKCE challenge and store verifier for later use.
 */
if (app.ports && app.ports.requestPkceChallenge) {
    app.ports.requestPkceChallenge.subscribe(async function() {
        try {
            const codeVerifier = generateCodeVerifier();
            const codeChallenge = await generateCodeChallenge(codeVerifier);

            // Store verifier in localStorage for retrieval after redirect
            localStorage.setItem('spotify_code_verifier', codeVerifier);

            // Send challenge back to Elm
            if (app.ports.receiveCodeChallenge) {
                app.ports.receiveCodeChallenge.send(codeChallenge);
            }
        } catch (error) {
            console.error('Failed to generate PKCE challenge:', error);
            if (app.ports.receiveAuthError) {
                app.ports.receiveAuthError.send(error.message);
            }
        }
    });
}

/**
 * Retrieve stored code verifier for token exchange.
 */
if (app.ports && app.ports.requestCodeVerifier) {
    app.ports.requestCodeVerifier.subscribe(function() {
        try {
            const codeVerifier = localStorage.getItem('spotify_code_verifier');
            if (!codeVerifier) {
                throw new Error('Code verifier not found. Please try logging in again.');
            }

            // Clean up stored verifier
            localStorage.removeItem('spotify_code_verifier');

            // Send verifier back to Elm
            if (app.ports.receiveCodeVerifier) {
                app.ports.receiveCodeVerifier.send(codeVerifier);
            }
        } catch (error) {
            console.error('Failed to retrieve code verifier:', error);
            if (app.ports.receiveAuthError) {
                app.ports.receiveAuthError.send(error.message);
            }
        }
    });
}
