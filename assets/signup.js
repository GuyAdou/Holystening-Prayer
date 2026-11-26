// Beta signup: validates the email, sends it to the Apps Script endpoint,
// and shows the confirmation panel only when the script says the email went out.
(function () {
  const MESSAGES = {
    invalidEmail: 'Enter a valid email address.',
    notConnected: 'Signups open soon. Please check back shortly.',
    busy: 'We’re getting a lot of signups right now. Please try again in an hour.',
    failed: 'Something went wrong. Please try again.',
    sent: 'We sent the beta link to',
    alreadySignedUp: 'You’re already on the list. We sent the beta link to',
  };
  const SENDING_LABEL = 'Joining…';
  const EMAIL_PATTERN = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

  function getSignupEndpoint() {
    const config = window.HOLYSTENING_CONFIG || {};
    return (config.betaSignupEndpoint || '').trim();
  }

  async function sendSignupRequest(endpoint, email, honeypotValue) {
    // Form-encoded body keeps this a "simple" request, so Apps Script needs no CORS preflight.
    const response = await fetch(endpoint, {
      method: 'POST',
      body: new URLSearchParams({ email: email, website: honeypotValue }),
    });
    return parseSignupReply(await response.text());
  }

  // Accepts both script versions: JSON ({"ok":true}) or plain text ("ok" / "invalid").
  function parseSignupReply(replyText) {
    try {
      return JSON.parse(replyText);
    } catch (notJson) {
      const plainReply = replyText.trim().toLowerCase();
      if (plainReply === 'ok') return { ok: true };
      if (plainReply === 'invalid') return { ok: false, error: 'invalid_email' };
      return { ok: false, error: 'unexpected_reply' };
    }
  }

  function showError(signupBlock, message) {
    const errorLine = signupBlock.querySelector('.form-error');
    errorLine.textContent = message;
    errorLine.hidden = false;
  }

  function clearError(signupBlock) {
    signupBlock.querySelector('.form-error').hidden = true;
  }

  function showConfirmationEverywhere(email, wasAlreadySignedUp) {
    document.querySelectorAll('[data-signup]').forEach(function (signupBlock) {
      signupBlock.querySelector('form').hidden = true;
      clearError(signupBlock);
      signupBlock.querySelector('[data-email]').textContent = email;
      signupBlock.querySelector('[data-done-message]').textContent =
        wasAlreadySignedUp ? MESSAGES.alreadySignedUp : MESSAGES.sent;
      signupBlock.querySelector('.beta-done').hidden = false;
    });
  }

  async function handleSubmit(signupBlock, form) {
    const emailInput = form.querySelector('input[name="email"]');
    const honeypotInput = form.querySelector('input[name="website"]');
    const submitButton = form.querySelector('button[type="submit"]');
    const email = emailInput.value.trim();

    if (!EMAIL_PATTERN.test(email)) return showError(signupBlock, MESSAGES.invalidEmail);
    const endpoint = getSignupEndpoint();
    if (!endpoint) return showError(signupBlock, MESSAGES.notConnected);

    clearError(signupBlock);
    const originalLabel = submitButton.textContent;
    submitButton.disabled = true;
    submitButton.textContent = SENDING_LABEL;
    try {
      const result = await sendSignupRequest(endpoint, email, honeypotInput.value);
      if (result && result.ok) return showConfirmationEverywhere(email, Boolean(result.alreadySignedUp));
      if (result && result.error === 'invalid_email') return showError(signupBlock, MESSAGES.invalidEmail);
      if (result && result.error === 'busy') return showError(signupBlock, MESSAGES.busy);
      showError(signupBlock, MESSAGES.failed);
    } catch (networkError) {
      showError(signupBlock, MESSAGES.failed);
    } finally {
      submitButton.disabled = false;
      submitButton.textContent = originalLabel;
    }
  }

  document.querySelectorAll('[data-signup]').forEach(function (signupBlock) {
    const form = signupBlock.querySelector('form');
    form.addEventListener('submit', function (event) {
      event.preventDefault();
      handleSubmit(signupBlock, form);
    });
    form.querySelector('input[name="email"]').addEventListener('input', function () {
      clearError(signupBlock);
    });
  });
})();
