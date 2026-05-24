---
name: Lumina Tech
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#393939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#bfc7d4'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#89919d'
  outline-variant: '#404752'
  surface-tint: '#9ecaff'
  primary: '#9ecaff'
  on-primary: '#003258'
  primary-container: '#2196f3'
  on-primary-container: '#002c4f'
  inverse-primary: '#0061a4'
  secondary: '#44d8f1'
  on-secondary: '#00363e'
  secondary-container: '#00bcd4'
  on-secondary-container: '#004650'
  tertiary: '#d3bbff'
  on-tertiary: '#3f008d'
  tertiary-container: '#a57af9'
  on-tertiary-container: '#39007f'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d1e4ff'
  primary-fixed-dim: '#9ecaff'
  on-primary-fixed: '#001d36'
  on-primary-fixed-variant: '#00497d'
  secondary-fixed: '#a1efff'
  secondary-fixed-dim: '#44d8f1'
  on-secondary-fixed: '#001f25'
  on-secondary-fixed-variant: '#004e59'
  tertiary-fixed: '#ebddff'
  tertiary-fixed-dim: '#d3bbff'
  on-tertiary-fixed: '#250059'
  on-tertiary-fixed-variant: '#5727a6'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 56px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Geist
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Geist
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 48px
  xl: 80px
  gutter: 24px
  margin-desktop: 64px
  margin-mobile: 16px
---

## Brand & Style

This design system is built for a high-performance, developer-centric environment where clarity and technical precision are paramount. The brand personality is focused, efficient, and sophisticated, aiming to evoke a sense of professional mastery and "flow state" productivity. 

The aesthetic follows a **Modern Minimalism** approach with subtle **Glassmorphism** influences. It prioritizes high-quality typography and a disciplined use of whitespace to manage information density. The goal is to provide a UI that feels virtually invisible, allowing the user's data and workflows to take center stage while providing tactile, high-fidelity feedback through subtle transitions and light-based depth.

## Colors

The palette is optimized for a high-contrast dark mode environment. The primary color is a vibrant blue used for high-intent actions and active states. Secondary and tertiary colors are used sparingly for data visualization, category tagging, and subtle accenting of interactive surfaces.

The neutral palette is grounded in a deep, near-black surface to reduce eye strain during extended use. Semantic colors (Success, Warning, Error) should be derived from the brand's saturation levels to maintain visual harmony. Surface colors are created by layering translucent white over the neutral base to indicate hierarchy.

## Typography

This design system utilizes a three-font strategy to differentiate information architecture. **Hanken Grotesk** provides a sharp, contemporary look for headlines. **Geist** offers exceptional legibility for body text and long-form content. **JetBrains Mono** is reserved for metadata, technical labels, and code snippets, reinforcing the developer-friendly nature of the product.

Hierarchy is established through weight and scale rather than color. Large display titles use tight letter spacing for a compact, architectural feel. Label styles are uppercase or monospaced to clearly distinguish them from interactive body text.

## Layout & Spacing

The design system employs a **Fluid Grid** layout with a baseline unit of 8px. This ensures mathematical consistency across all margins, paddings, and component dimensions. 

- **Desktop (1440px+):** 12-column grid with 24px gutters and 64px side margins.
- **Tablet (768px - 1439px):** 8-column grid with 24px gutters and 32px side margins.
- **Mobile (Up to 767px):** 4-column grid with 16px gutters and 16px side margins.

Complex data views should utilize a "Main-Detail" split screen on desktop, reflowing into a stacked view or modal-based detail view on mobile.

## Elevation & Depth

Depth is communicated through **Tonal Layers** and **Backdrop Blurs** rather than traditional heavy shadows. In this dark mode environment:
- **Level 0 (Base):** Pure neutral black (#121212).
- **Level 1 (Cards/Containers):** Neutral color with a 4% white overlay and a subtle 1px border (#ffffff at 10% opacity).
- **Level 2 (Modals/Dropdowns):** Neutral color with an 8% white overlay, a 20px background blur, and a soft ambient glow (primary color at 5% opacity, 40px blur).

Interactive elements use a "light-source" metaphor: hover states increase the brightness of the surface overlay rather than adding physical lift.

## Shapes

The design system uses a **Soft** shape language to balance the technical rigidity of the typography. The 4px (0.25rem) base radius provides a modern, approachable feel without appearing overly "bubbly." 

- Standard components (Inputs, Buttons): 4px radius.
- Large containers (Cards, Modals): 8px (rounded-lg) radius.
- System-wide icons and decorative elements should mirror these radii for visual cohesion.

## Components

### Buttons
Primary buttons use a solid primary color fill with white text. Secondary buttons use a ghost style with a 1px border and a subtle background fill on hover. Tertiary buttons are text-only with an underline appearing on hover.

### Input Fields
Inputs feature a dark background (Level 1 elevation) with a 1px border. Focus states are indicated by a 2px primary color border and a subtle inner glow. Labels use the `label-sm` monospaced font style positioned above the field.

### Cards
Cards are the primary container for content. They use Level 1 elevation with a subtle 1px border. On hover, the border color shifts toward the primary brand color to indicate interactivity.

### Chips & Tags
Chips are used for filtering and metadata. They use a pill-shape (fully rounded) regardless of the system's soft-corner rule to distinguish them from buttons.

### List Items
Lists should have generous vertical padding (16px) and use thin dividers (1px, 5% white opacity). Active or selected states use a vertical primary-colored bar on the left edge.

### Additional Components
- **Code Blocks:** High-contrast containers using Level 2 elevation and JetBrains Mono.
- **Status Indicators:** Small, glowing dots (10px) using semantic colors with a 4px outer blur to simulate a hardware LED.