# Mechanical Step 02 — OpenGrid Architecture

## Purpose

This step redesigns the mechanical architecture around OpenGrid as the structural base.

The previous pot-first approach was rejected because the system requires a real load-bearing attachment to OpenGrid. The corrected design uses a carrier-first model.

## Module hierarchy

- OpenGrid interface abstraction
- Carrier frame (structural)
- Pot insert (removable)
- Sensor holder (insert-mounted)
- Tube clip (insert-mounted)
- Electronics plate (OpenGrid-mounted)

## Design rules

- Load path goes through carrier and OpenGrid
- Pot insert is removable and non-structural
- Wet and dry modules remain separate
- OpenGrid geometry is abstracted into an interface layer until exact dimensions are confirmed

## Outcome

This step establishes the correct CAD and structural foundation for the MVP node.