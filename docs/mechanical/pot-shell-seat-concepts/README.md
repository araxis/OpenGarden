# Pot-to-Shell Rim and Seat Concepts

This note captures the current OpenGarden v2 direction for seating removable pot inserts in a printable top shell.

## Selected Direction

Use a reusable sloped rim/seat mechanism:

- The pot body remains a real printed part with fixed `Pot_Height`.
- `Pot_Insert_Depth` moves the rim along Z and controls how far the pot sits into the shell.
- The grid cell describes the outer rim footprint.
- The through-hole is smaller than the rim footprint by `rim_w * 2`.
- The shell cut uses a shallow sloped seat plus a through-hole.

This matches countertop herb planter products where small pot cups hang from a top deck by their rim.

## Printability Rules

- Avoid flat horizontal rim shelves when printing the pot upright.
- Prefer a sloped shoulder: `rim_height >= rim_width` is the safe default.
- Keep the shell seat shallow and chamfered/sloped.
- Use a small cut epsilon for subtractive tools so cut faces do not end exactly on shell faces.
- Keep rim and seat dimensions parameterized because the same pattern should be reused by future components.

## Current Parameters

```scad
Pot_Height = 55;
Pot_Insert_Depth = 37;
Pot_Rim_Width = 3;
Pot_Rim_Height = 3;
Shell_Seat_Depth = 2.4;
Shell_Pot_Clearance = 0.4;
```

## Concept Images

- `01-chamfer-seat.svg`: original chamfer-seat idea.
- `02-support-base.svg`: reservoir support-base alternative.
- `03-bayonet-lock.svg`: twist-lock alternative.
- `04-depth-collar.svg`: removable spacer/collar alternative.

The selected implementation is closest to `01-chamfer-seat.svg`, but uses a sloped printable rim rather than a square flange.
