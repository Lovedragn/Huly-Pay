I need you to fix the existing HulyPay Flutter splash-screen logo animation.

IMPORTANT:

- I have uploaded the ORIGINAL `Logo-Dark.svg`.
- I have also provided the current Flutter splash-screen implementation.
- The original SVG must be treated as the SINGLE SOURCE OF TRUTH for the logo geometry.
- Do NOT manually redraw, approximate, simplify, mirror, or recreate the logo paths.
- Do NOT change the actual logo design.
- Do NOT replace the original SVG with a different logo.
- Preserve the existing splash-screen UI, black background, branding text, navigation logic, authentication logic, and timing unless a change is specifically required for the logo animation.

## CURRENT PROBLEM

The current implementation manually reconstructs SVG paths in Dart and animates those paths using `PathMetric`.

The animation has problems:

1. The generated SVG paths do not perfectly match the original `Logo-Dark.svg`.
2. The logo geometry becomes slightly distorted/misaligned during animation.
3. The pointer/light-tracing element does not stay exactly on the path being drawn.
4. The pointer can appear ahead of or behind the path.
5. Some blade/path drawing directions are visually unnatural.
6. The logo/ring alignment is slightly incorrect.
7. The current painter assumes:

```dart
const double vbWidth = 658.0;
const double vbHeight = 649.0;
```

Do NOT assume these dimensions. Read the actual `viewBox` and geometry from the uploaded `Logo-Dark.svg`.

8. The current implementation manually creates the outer ring using hard-coded coordinates. This should not be used if the original SVG already contains the corresponding geometry.

## REQUIRED APPROACH

### 1. Use the ORIGINAL SVG geometry

Inspect `Logo-Dark.svg` carefully.

Determine:

- exact `viewBox`
- all `<path>` elements
- transforms
- groups
- clipping paths
- fills
- strokes
- path ordering
- coordinate system

The rendered logo must visually match the original SVG exactly when the animation is complete.

Do NOT use the existing manually hard-coded `_initPaths()` geometry as the source of truth.

If necessary, replace the current manually reconstructed `_paths` implementation completely.

### 2. Preserve exact aspect ratio

The logo must be scaled uniformly.

Never independently scale X and Y.

Use:

```text
scale = min(targetWidth / svgWidth, targetHeight / svgHeight)
```

and center the SVG geometry inside the target widget.

The logo must never stretch, squash, or shift while animating.

### 3. Fix the path drawing animation

The animation should reveal the ORIGINAL SVG paths progressively.

Do not simply assume that every path should be drawn from:

```dart
metric.extractPath(0.0, metric.length * progress)
```

without checking the visual direction.

The drawing direction must produce a smooth and intentional logo formation.

If a path's natural direction is incorrect for the animation, reverse that path's animation direction mathematically rather than changing its geometry.

Do NOT modify the SVG path coordinates just to make the animation work.

### 4. Fix the pointer

This is extremely important.

The pointer/tracer must be attached to the ACTUAL animated path.

It must NOT use an independently calculated X/Y position.

At every animation frame:

```text
pointer position = current endpoint of the currently animated SVG path
```

The pointer should therefore remain exactly on the path.

Use the actual `PathMetric` / tangent information where appropriate:

```dart
final tangent = metric.getTangentForOffset(offset);
```

and derive:

```text
position
rotation
```

from the tangent.

The pointer must move along the path naturally and smoothly.

It should never:

- float away from the path
- jump between paths
- lag behind the stroke
- move faster than the stroke
- appear at a mathematically unrelated position

### 5. Smooth path sequencing

Do NOT animate all paths blindly at exactly the same time.

Create a carefully coordinated sequence based on the actual SVG geometry.

Desired visual behavior:

```text
0.00 ─────────────── 0.10
        Initial reveal / pointer starts

0.10 ─────────────── 0.38
        Pointer traces the logo contours

0.30 ─────────────── 0.52
        White logo fill progressively appears

0.52 ─────────────── 0.65
        Pointer/tracer completes and disappears

0.65 ─────────────── 0.80
        Clean logo settles
```

The exact timing can be adjusted slightly if required to make the animation visually smooth.

The complete logo animation should feel approximately 0.6–0.8 seconds, not slow or mechanical.

### 6. Pointer behavior

The pointer should behave like a small luminous drawing head.

Requirements:

- small
- subtle
- smooth
- white/light
- follows the path exactly
- rotates according to path tangent when appropriate
- no large glow
- no distracting particle effects
- no independent floating movement

If the current pointer implementation does not exist or is incorrect, implement it inside the logo painter rather than creating a separate animation with unrelated coordinates.

### 7. Fill animation

The final logo should become the exact solid white logo from the original SVG.

The fill should fade/reveal naturally after the path tracing begins.

Do not change:

- blade proportions
- logo silhouette
- internal spacing
- logo dimensions
- center point
- original SVG geometry

The final frame should be visually indistinguishable from rendering the original `Logo-Dark.svg` as a static SVG.

### 8. Outer ring

The current implementation manually creates an outer circular guide ring with hard-coded coordinates.

Do NOT keep this if the original SVG already contains the correct ring/outline.

Use the actual SVG geometry where possible.

If the ring is intentionally an animation-only effect and is NOT part of the original SVG, keep it only if it visually aligns exactly with the original logo.

It must not introduce a second incorrectly positioned circle.

### 9. Do not break the splash screen

Do NOT modify unrelated application logic.

Preserve:

- `_initializeAppAndAuth()`
- authentication checks
- cached user logic
- Supabase initialization
- navigation
- `_navigateToNext()`
- branding text
- black OLED background
- Hero tag
- native splash removal
- tap-to-skip behavior

Only modify the logo animation implementation and anything directly required for its correct rendering.

## IMPORTANT TECHNICAL REQUIREMENT

Before editing the code, inspect the actual uploaded `Logo-Dark.svg`.

Do not rely on the hard-coded path values already present in the Dart file.

The original SVG is authoritative.

If Flutter's normal SVG rendering package cannot expose the individual paths required for progressive path animation, use an appropriate SVG parsing approach or preprocess the SVG geometry at build/runtime.

Do NOT manually copy hundreds of coordinates from the SVG into Dart.

The implementation should remain maintainable.

## EXPECTED CODE STRUCTURE

Prefer something conceptually similar to:

```dart
class AnimatedHulyLogo extends StatelessWidget {
  ...
}
```

and:

```dart
class LogoStrokePainter extends CustomPainter {
  ...
}
```

but these classes may be redesigned if required.

The important requirement is:

```text
Original Logo-Dark.svg
        ↓
Exact SVG geometry
        ↓
Correct transform/viewBox
        ↓
Animated path extraction
        ↓
Pointer attached to actual path endpoint
        ↓
Exact final logo
```

NOT:

```text
Original SVG
   ↓
manually guessed paths
   ↓
hard-coded coordinates
   ↓
misaligned animation
```

## PERFORMANCE

This is a Flutter mobile splash screen.

Keep the animation lightweight.

Avoid:

- unnecessary rebuilds
- excessive widget creation
- expensive SVG parsing every frame
- parsing the SVG repeatedly inside `paint()`
- unnecessary network/file operations
- multiple animation controllers for the same animation

Parse/cache geometry once and animate only the necessary values per frame.

The animation must remain smooth on Android release builds.

## VALIDATION

After implementing the fix:

1. Compare the static final rendered logo against the uploaded `Logo-Dark.svg`.
2. Verify that the logo has exactly the same proportions.
3. Verify that the center alignment is correct.
4. Verify that the pointer stays exactly on the active path.
5. Verify that no path jumps occur.
6. Verify that no blade is mirrored or distorted.
7. Verify that the ring is not incorrectly offset.
8. Verify that the logo does not stretch during scaling.
9. Test the animation in a Flutter RELEASE build.
10. Confirm there are no Flutter analyzer errors or warnings caused by the changes.

## VERY IMPORTANT

Do not stop after making the code compile.

Actually inspect the animation visually.

If the pointer is not perfectly attached to the path, fix the geometry/path sequencing rather than compensating with arbitrary X/Y offsets.

Do not use magic offsets such as:

```dart
pointerX + 12
pointerY - 8
```

to hide alignment problems.

The correct solution is to derive the pointer position from the actual SVG path/tangent.

Likewise, do not "fix" the logo by manually changing individual path coordinates.

The original `Logo-Dark.svg` must remain the source of truth.

Finally, show me:

1. Which files you changed.
2. What was causing the original path/pointer misalignment.
3. How the new implementation uses the original SVG geometry.
4. Any dependencies added or removed.
5. The final animation timing.
6. Confirmation that the existing splash/auth/navigation behavior was preserved.
