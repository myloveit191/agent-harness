# Styling And UI Policy

Use the styling system already present in the project.

## Discovery

Inspect:

- Global styles.
- CSS Modules.
- Tailwind configuration.
- PostCSS configuration.
- Component library setup.
- Theme tokens or design-system packages.
- Existing responsive and accessibility patterns.

## UI Changes

- Match the existing component composition and naming style.
- Keep responsive behavior explicit for mobile, tablet, and desktop when the
  touched UI is user-facing.
- Use semantic HTML and accessible labels for controls.
- Preserve focus states and keyboard navigation.
- Avoid layout shifts from images, dynamic labels, and loading states.
- Do not add a new UI framework or icon library without approval.

## Assets

- Use `public/` for static project assets when that is the local convention.
- Prefer the project's established image component and optimization strategy.
- Provide width, height, aspect ratio, or stable container dimensions for media.
