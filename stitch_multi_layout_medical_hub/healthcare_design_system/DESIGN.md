---
name: Healthcare Design System
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#434653'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#737784'
  outline-variant: '#c3c6d5'
  surface-tint: '#1d59c1'
  primary: '#003c90'
  on-primary: '#ffffff'
  primary-container: '#0f52ba'
  on-primary-container: '#bcceff'
  inverse-primary: '#b0c6ff'
  secondary: '#006b5f'
  on-secondary: '#ffffff'
  secondary-container: '#6df5e1'
  on-secondary-container: '#006f64'
  tertiary: '#394246'
  on-tertiary: '#ffffff'
  tertiary-container: '#50595e'
  on-tertiary-container: '#c6cfd5'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d9e2ff'
  primary-fixed-dim: '#b0c6ff'
  on-primary-fixed: '#001945'
  on-primary-fixed-variant: '#00419c'
  secondary-fixed: '#71f8e4'
  secondary-fixed-dim: '#4fdbc8'
  on-secondary-fixed: '#00201c'
  on-secondary-fixed-variant: '#005048'
  tertiary-fixed: '#dbe4ea'
  tertiary-fixed-dim: '#bfc8ce'
  on-tertiary-fixed: '#141d21'
  on-tertiary-fixed-variant: '#3f484d'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 80px
---

## Brand & Style

The design system is anchored in the core values of **Trust, Precision, and Empathy**. It is designed for patients and healthcare providers who require immediate clarity and a sense of calm during potentially stressful interactions. 

The aesthetic follows a **Modern Corporate** direction infused with **Minimalist** principles. By prioritizing generous whitespace and a restricted color palette, the UI minimizes cognitive load, ensuring that critical medical information is always the focal point. The visual language is intentionally soft—avoiding harsh edges or aggressive contrasts—to evoke a professional yet approachable medical environment.

## Colors

The color strategy for the design system utilizes "Medical Blue" as the foundation for authority and reliability. "Soft Teal" acts as a secondary accent, used primarily for health-positive actions, success states, and navigational highlights.

- **Primary (Medical Blue):** Reserved for primary actions, branding, and active states.
- **Secondary (Soft Teal):** Used for wellness-related features, icons, and supporting buttons.
- **Neutral:** A range of cool-toned slates that maintain a clean, clinical feel without the harshness of pure black.
- **Backgrounds:** Primarily off-white and very light blue tints to define content areas without using heavy borders.

## Typography

This design system utilizes **Inter** for all levels of the hierarchy. Inter's tall x-height and systematic spacing make it ideal for legibility in medical contexts, such as reading prescription dosages or doctor names.

The type scale is generous. Large display titles are used for dashboard welcomes, while a strict hierarchy of "Body" and "Label" styles manages data-heavy patient records. Letter spacing is slightly tightened on headlines for a premium feel and widened on small labels to ensure accessibility and readability at small sizes.

## Layout & Spacing

The layout utilizes a **12-column fluid grid** for desktop and a **4-column grid** for mobile. The spacing philosophy is built on an **8px base unit** to ensure mathematical harmony across all components.

- **Generous Whitespace:** To prevent the UI from feeling "crowded" (which can increase patient anxiety), section margins are set to a minimum of 40px (lg) on desktop.
- **Grid Alignment:** Elements like doctor profile cards should span 3 columns on desktop (grid view) or the full width of the content container (list view).
- **Safe Areas:** Mobile layouts must respect a 16px side margin to ensure content is not clipped by device bezels or cases.

## Elevation & Depth

Visual hierarchy in the design system is achieved through **Tonal Layering** and **Ambient Shadows**. Instead of heavy borders, surfaces are separated by subtle shifts in background color and soft, diffused shadows.

- **Level 0 (Base):** The main background using a clean white or light blue tint (#F8FAFC).
- **Level 1 (Cards/Banners):** Features a very soft, high-blur shadow with a hint of the primary blue in the shadow's color (e.g., `rgba(15, 82, 186, 0.05)`). This creates a "floating" effect that guides the user's eye to interactive areas.
- **Level 2 (Modals/Search Bar Focus):** Increased shadow spread and a subtle 1px border in a light neutral tone to provide clear definition against the base.

## Shapes

The shape language is consistently **Rounded**. This softens the clinical nature of the app, making it feel more modern and user-friendly.

- **Standard Components:** Buttons, input fields, and small chips use a 0.5rem (8px) radius.
- **Large Containers:** Doctor profile cards and horizontal banners use a 1rem (16px) radius to create a distinct "pod" look that is approachable and soft.
- **Full Rounded:** Social communication icons (e.g., the "Call" or "Message" buttons) often use a pill-shape or circular container to distinguish them as high-priority actions.

## Components

### Doctor Profile Cards
- **Grid View:** Top-aligned photo, followed by Name (Title-LG), Specialty (Label-MD), and a Rating chip. Primary action button at the bottom.
- **List View:** Horizontal orientation with a left-aligned circular avatar, central metadata, and right-aligned "Book Now" button. High use of horizontal padding (16px-24px).

### Search Bars
- Search bars should be full-width on mobile with a persistent search icon on the left. The background should be a very light neutral (#F1F5F9) with a 1px border that turns Primary Blue on focus.

### Horizontal Banners
- Used for promotions or urgent health alerts. These should utilize the Secondary (Teal) or Primary (Blue) as a background with white text. Use high-quality, clinical photography or minimalist medical illustrations on the right side of the banner.

### Communication Icons
- Icons for calling or messaging a doctor should be enclosed in a soft-teal circular background. Use clear, thick-stroke (2px) line icons to ensure they are recognizable even at small sizes.

### Buttons & Inputs
- Primary buttons are solid Blue with white text.
- Secondary buttons are Teal with white text, or Blue outlines.
- Inputs must have clear labels and generous vertical padding (12px) for ease of use on touch screens.