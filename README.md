# Holystening website

Landing page for Holystening, the distraction-free prayer app. Plain HTML, CSS and JavaScript, hosted on GitHub Pages.

## Files

The privacy policy lives on Notion: https://guygeorges.notion.site/Holystening-Privacy-Policy-3c14ecc10ee981c7a55bee150ddbb8ea (the footer's Privacy link).


| Path | What it is |
|---|---|
| `index.html` | The landing page |
| `assets/config.js` | Site settings: the beta signup endpoint |
| `assets/signup.js` | Beta signup form logic |
| `assets/fonts.css`, `fonts/` | Self-hosted Bricolage Grotesque and Instrument Sans (SIL Open Font License) |
| `images/` | Phone mockups, app icon, favicon, social preview |

## Connect the beta signup

- [ ] Deploy the Apps Script (`Code.gs`) as a web app from holystening@gmail.com
- [ ] Copy the web app URL (ends in `/exec`)
- [ ] Paste it into `betaSignupEndpoint` in `assets/config.js`
- [ ] Commit and push
- [ ] Sign up once on the live site with your own email
- [ ] Check the email arrived and the Sheet has a `sent` row

Until the endpoint is set, the form shows "Signups open soon."

## Add the custom domain

- [ ] At the domain registrar, add four A records for the bare domain: `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
- [ ] Add a CNAME record for `www` pointing to `guyadou.github.io`
- [ ] Add a `CNAME` file to this repo containing only the domain (for example `holystening.com`)
- [ ] In GitHub: Settings → Pages → Custom domain → enter the domain → Save
- [ ] Once the certificate is ready, tick Enforce HTTPS

## Edit the page

The design lives in the "Holystening website design" canvas on Claude. After changing it there, regenerate `index.html` or edit `index.html` directly.
