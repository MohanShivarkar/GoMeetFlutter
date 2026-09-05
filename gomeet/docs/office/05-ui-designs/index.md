# UI Designs

## Design Direction

GoMeet PWA adopts a dark-primary visual identity — deep navy backgrounds (`#0F0F1A`) contrasted with a bold rose-to-coral gradient (`#FF4458 → #FF6B35`) that carries across CTAs, the logo, and interactive highlights. The tone is warm and energetic without being garish: text in white and muted greys keeps readability high while the gradient accent communicates the brand's playful confidence. All screens use system fonts only and are rendered at realistic viewport widths (390 px for mobile phone frames, 820–960 px for tablet browser frames) to reflect the two primary GoMeet PWA user contexts.

---

## Mockups

### 1. Sign In / Landing
File: ./01-sign-in.html

From the user's perspective, the sign-in screen is the first impression of the PWA — and for the Browser Discoverer persona it must immediately justify the decision *not* to install a native app. The design uses a full-bleed hero gradient (matching the brand's mobile app) with the GoMeet logo and the core tagline, "Dating without the download." Below the fold, the form is streamlined: email + password with inline icons, a clear password-reset link, a Google Sign-In button (the highest-friction reducer for new users), and a phone-number auth option. A subtle "Install GoMeet to your desktop" banner at the bottom proactively surfaces the PWA install CTA without blocking the authentication flow. Auth state persistence is implied by the absence of any "remember me" toggle — Firebase `LOCAL` persistence is always on.

---

### 2. Profile Creation — Photos Step (Step 3 of 5)
File: ./02-profile-creation.html

This flow has friction at the photo upload step — it is the moment most new web users drop off. The design tackles this with three parallel affordances: a camera capture button (using `getUserMedia` on web), a file-picker upload, and drag-to-reorder within the 3×2 photo grid. A coloured progress bar and explicit step labels (Name → Birthday → **Photos** → Bio → Prefs) orient the user within the five-step stepper. The primary photo slot spans two grid rows to reinforce its visual hierarchy. A "GoMeet Photo Tips" card below the grid uses social proof ("profiles with smiling photos get 40% more likes") to motivate completion before the user taps Next. The bottom bar shows overall profile completeness (60%) alongside Back / Continue buttons, making progress feel tangible and reversible.

---

### 3. Discover / Swipe (Tablet 820 px Viewport)
File: ./03-discover.html

Users will expect the Discover screen to feel identical to the mobile app — the key web challenge is translating drag-gesture swipe cards to mouse interaction and larger screens. This mockup shows the tablet-adaptive layout at 820 px: the card stack is centred at ~320 px width with stacked background cards suggesting depth, while all action buttons (Rewind, Nope, Super Like, Like, Boost) are surfaced in a vertical sidebar to the right of the card rather than buried below it. This eliminates the need to scroll on larger screens and keeps all controls in the user's peripheral vision. A keyboard shortcut hint bar (← Nope, ↑ Super, → Like) fulfils the PRD's accessibility requirement and differentiates the web experience positively. The browser chrome shows the PWA install CTA in the address bar area, turning the discovery session itself into an install funnel touchpoint.

---

### 4. Chat — Two-Panel Tablet Layout (960 px Viewport)
File: ./04-chat.html

To make this more intuitive on tablet and desktop, the Chat screen switches from single-panel to a master-detail layout at ≥768 px. The left panel (290 px) combines a new-matches strip (with gradient avatar rings) above the full conversation list — each conversation row shows avatar, name, last message preview, timestamp, and an unread badge. The active conversation highlights with a red left-edge accent. The right panel hosts the full message thread: a header with the match's name, online status, and action buttons (photo share, email, overflow); a scrollable message history with realistic Mumbai-based conversation content; animated typing dots for the incoming-message state; and a composable input bar with emoji and image-attach buttons. This layout mirrors Tinder's desktop two-column chat UX but is built to exact PRD spec (≥768 px two-panel, <768 px single-panel).

---

### 5. PWA Install Prompt & Offline Shell
File: ./05-pwa-install.html

This screen covers two distinct but related PWA-specific UX moments shown side by side. **Panel A** depicts the Chrome `beforeinstallprompt` bottom sheet — the blurred app shell behind it creates context while the sheet itself presents the GoMeet icon, three feature callouts (instant access, offline capability, notifications), and two clear CTAs. The design intentionally does not auto-dismiss the prompt; users must explicitly choose "Not now" to continue in browser, which the PRD identifies as a key conversion metric to track. **Panel B** depicts the offline shell state: the service-worker cache keeps the full app chrome, navigation bar, and locally cached match avatars visible, replacing live content with an offline illustration and a warm explanatory message. A "Cached as of [time]" disclosure manages expectations honestly, and a "Try reconnecting" button lets users retry without confusion — a significant UX advantage over every competitor that shows a raw browser error page.
