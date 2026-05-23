---
name: basalt-ui-design
description: Basalt CC:Tweaked XML screenshot mockup UI design. Use when the user wants a Basalt interface recreated from a screenshot, visual mockup, reference image, or general frontend-style design translated into terminal-safe Basalt XML.
---

# Basalt UI Design

Use this skill when building or refining UI for `Basalt` in `CC:Tweaked`, especially when the user provides:

- a screenshot
- a mockup
- a website reference
- a design description
- a request for a more polished Basalt XML UI

This skill is for translating visual design into a terminal-native Basalt implementation, not for normal web frontend code.

## Goal

Turn a visual reference into the closest practical Basalt UI by preserving:

- layout
- spacing
- hierarchy
- emphasis
- interaction intent

Always ensure generated Basalt layouts work across different screen sizes unless the user explicitly requests a fixed-size layout for a known monitor size.

Do not chase unsupported web visuals when the terminal cannot reproduce them.

## Basalt Reality Check

Basalt runs in a terminal-like grid. Treat every design through that constraint first.

Supported well:

- frames
- labels
- buttons
- inputs
- lists
- simple layout groupings
- solid colors
- borders
- centered composition

Not truly supported like the web:

- blur
- box-shadow
- rounded corners
- soft gradients
- freeform typography
- true padding systems like CSS
- centered editable text in normal inputs

Approximate these by focusing on:

- larger framed regions
- whitespace
- color contrast
- simple borders
- careful vertical rhythm

## Default Output Shape

Prefer:

1. Minimal `main.lua` bootstrap only
2. XML for layout and static styling
3. Lua only for loading XML and wiring behavior the XML cannot express cleanly

Default bootstrap shape:

```lua
local basalt = require("basalt")

local main = basalt.getMainFrame()
local xmlFile = fs.open("ui.xml", "r")

main:loadXML(xmlFile.readAll())
xmlFile.close()

basalt.run()
```

## Screenshot Translation Workflow

When given a screenshot or mockup:

1. Identify the main blocks
2. Identify the visual hierarchy
3. Separate must-match structure from optional decoration
4. Translate each block into Basalt primitives
5. Remove unsupported visual effects early
6. Build the safest XML structure that still resembles the reference

### Step 1: Identify the blocks

Break the screenshot into:

- page background
- title/header
- form row(s)
- grouped boxes/cards
- primary button
- secondary actions

### Step 2: Identify the hierarchy

Ask:

- what should the eye see first?
- what should feel clickable?
- which spacing implies grouping?
- are labels inline, above, or implied by placeholders?

### Step 3: Decide what to fake and what to keep

Keep:

- composition
- alignment
- spacing ratios
- relative sizing
- call-to-action emphasis

Drop or approximate:

- blur -> plain background color
- rounded corners -> rectangular frame/button
- drop shadow -> stronger contrast or border
- fancy cards -> bordered frame with empty space

### Step 4: Check screen-size safety

Before finalizing the layout, verify:

- the main composition still fits on narrower monitors
- labels are short enough for likely small widths
- widths and positions come from `parent.width` and `parent.height` when practical
- fixed-size inner containers are only used when a known minimum monitor size is acceptable
- spacing can compress before content starts clipping

## Basalt Element Mapping

Common translations:

- page/container -> `frame`
- panel/card -> `frame`
- title text -> `label`
- editable field -> `input`
- action CTA -> `button`
- row layout -> manually positioned children or `flexbox`

Prefer manual positioning for simple centered mockups. Use `flexbox` only when it actually simplifies the layout.

## Positioning Rules

Use integer-safe positioning.

Prefer relative sizing and positioning derived from `parent.width` and `parent.height` over hardcoded dimensions.

Good:

```xml
x="{math.floor(parent.width / 2 - self.width / 2)}"
y="{math.floor(parent.height / 2 - self.height / 2)}"
```

Avoid fractional expressions that can render at half-cells and break Basalt rendering.

If a centered label has fixed text and fixed parent width, hardcoding its position is often safer than another reactive expression.

Avoid fixed-width centered containers that can push content off-screen on smaller monitors unless the user explicitly wants a layout for a known screen size.

## Responsive Design Rules

Default to responsive layouts.

Guidelines:

1. Base outer layout width and height on `parent.width` and `parent.height`
2. Center elements with integer-safe expressions instead of fixed offsets when possible
3. Prefer widths derived from the parent frame over fixed button or panel widths
4. Keep labels short enough to fit narrow monitors without clipping
5. Reduce spacing, shorten text, or narrow controls before allowing overflow
6. Treat visual fidelity as secondary to fitting and remaining usable on-screen
7. Only use fixed-size inner panels when the user explicitly targets a known minimum monitor size

Safe patterns:

- `width="{math.max(14, parent.width - 4)}"`
- `x="{math.max(1, math.floor(parent.width / 2 - self.width / 2))}"`
- `y` positions derived from `parent.height` with `math.floor`

Be careful with:

- long single-line headers
- stacked sections that assume a tall monitor
- wide centered panels with hardcoded widths
- decorative wrapper frames that consume usable space on small screens

## Input Design Rules

Basalt inputs are real terminal text fields.

Important constraints:

- they are fundamentally single-line
- typed text is left-aligned
- placeholder text is not a true web-style centered placeholder
- visual padding is limited

Guidelines:

1. Do not promise centered typed text
2. If the mockup suggests large inputs, use a larger surrounding frame or wider field
3. Prefer placeholders when the reference implies inline labels
4. Avoid extra labels above inputs unless the layout truly needs them
5. If a bordered 1-line input looks cramped, use a wider field or a visual wrapper

## Boxed Input Strategy

When the mockup shows large rounded or padded boxes, use one of these strategies.

### Strategy A: Wide direct inputs

Use when stability matters most.

- wide `input`
- white background
- optional border only if Basalt handles it safely
- placeholder for implied label

### Strategy B: Visual wrapper + inner input

Use when the large box look matters more.

- outer `frame` as the visible box
- inner `input` for typing
- no border on the inner input
- keep positions integer-safe

If Basalt runtime errors appear, fall back to Strategy A.

## Button Design Rules

Buttons usually translate well.

For screenshot-style CTAs:

- make the button larger than surrounding inputs when appropriate
- use a stronger color than the rest of the screen
- keep text short
- center it visually under the form group

## Color Rules

Because the terminal palette is limited:

- use contrast more than subtlety
- prefer one neutral background color
- keep inputs white or light if the mockup is clean/minimal
- use one accent color for the primary action
- avoid overusing borders everywhere

## XML-First Guidance

Prefer expressing in XML:

- element tree
- x/y/width/height
- background/foreground
- text
- placeholder
- border properties

Keep Lua for:

- loading XML
- input submission behavior
- reading values on button click
- any logic XML cannot express cleanly

## Safety Rules

When building Basalt XML from screenshots:

1. Keep the structure as small as possible
2. Prefer fewer wrappers
3. Be cautious with nested interactive elements
4. Keep all computed positions integer-safe
5. Ensure the layout still fits across different screen sizes by default
6. If a more decorative structure causes runtime errors or clipping, simplify immediately

## Debugging Checklist

If the UI crashes or renders incorrectly, check in this order:

1. Fractional `x` or `y` expressions
2. Nested inputs inside styled wrappers
3. Bordered 1-line inputs
4. Unsupported property combinations in XML
5. Overly clever reactive expressions

### Known problem patterns

- `x="{parent.width / 2 - self.width / 2}"` without `math.floor`
- large nested wrapper trees for simple forms
- trying to make Basalt inputs behave like HTML inputs
- fixed-width centered panels wider than the actual monitor
- long labels that only fit on large monitors

### Safe fallback path

If the design starts breaking:

1. remove decorative wrappers
2. keep direct inputs
3. switch fixed widths to parent-relative widths
4. shorten labels or split them across lines
5. reduce spacing between sections
6. use placeholders instead of extra labels
7. preserve the composition, not the exact decoration

## Response Pattern

When implementing from a screenshot:

1. State the terminal-specific compromises briefly
2. Build the closest stable XML layout
3. Make sure it remains usable across different screen sizes by default
4. Keep behavior minimal unless requested
5. Explain any mismatch caused by Basalt limitations

Do not over-explain unless the user asks.

## Example Translation

Reference pattern:

- centered title
- three horizontal location inputs
- green `Go` button
- soft modern web styling

Basalt translation:

- light gray background frame
- centered responsive layout sized from the parent frame
- title label near top center
- three wide white inputs or three boxed input regions
- green button centered below
- no blur, no rounded corners, no shadows

## Design Heuristics

Prioritize these in order:

1. Usability across screen sizes
2. Layout fidelity
3. Spacing fidelity
4. Interaction correctness
5. Color hierarchy
6. Decorative resemblance

If forced to choose, prefer a stable and usable Basalt UI over a visually clever one that crashes.
