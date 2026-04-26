# Mechanical Step 01 — MVP Module Definition

## 🎯 Purpose

This step defines the **mechanical foundation** of the OpenGarden system.

The goal is to establish a **clean, modular, and scalable architecture** for a single plant unit (MVP), before any detailed CAD modeling begins.

This is not about designing shapes — it is about defining **interfaces, constraints, and structure**.

---

## 🧱 System Overview

The MVP consists of a **single plant module** with independent components:

* Pot body (structural + soil container)
* Sensor holder (fixed-position, replaceable)
* Tube nozzle clip (controlled water delivery)
* Electronics mount (separate dry-zone component)

![OpenGarden module hierarchy](../../images/diagrams/module-hierarchy.svg)

Each part is designed to be:

* Modular
* Replaceable
* Independently printable

---

## 🧩 Module Breakdown

### A. Pot Body

Main structural component.

Responsibilities:

* Hold soil and plant
* Provide drainage
* Attach to grid/frame (OpenGrid / Underware)
* Accept mounting for sensor and tube modules

---

### B. Sensor Holder

Separate component for sensor positioning.

Responsibilities:

* Maintain fixed insertion depth
* Prevent movement due to soil disturbance
* Allow easy removal/replacement

---

### C. Tube Nozzle Clip

Controls water delivery point.

Responsibilities:

* Hold tube securely
* Define drip location
* Prevent uncontrolled water spread

---

### D. Electronics Mount

Dry-zone mounting plate.

Responsibilities:

* Hold ESP32, power module, switching components
* Mount independently from pot
* Enable safe cable routing

---

### E. Future Module (Not in MVP)

Water distribution hub.

Planned for:

* Multi-pot systems
* Centralized pumping
* Fluid routing

---

## 📐 Mechanical Specifications (MVP)

| Parameter           | Value        |
| ------------------- | ------------ |
| Pot footprint       | 160 x 160 mm |
| Pot height          | 150 mm       |
| Wall thickness      | 2.4 mm       |
| Bottom thickness    | 3.0 mm       |
| Drain holes         | 2 x 8 mm     |
| Sensor depth        | 60 mm        |
| Tube outer diameter | 6 mm         |

---

## 🧠 Design Principles

### 1. Modular

Each component is independent and replaceable.

### 2. Printable

All parts must be printable on standard home 3D printers with minimal support.

### 3. Serviceable

Sensors, tubes, and electronics must be easy to access and replace.

### 4. Scalable

The same interfaces must support future multi-pot systems.

### 5. Reliable

Design must minimize:

* water leakage risk
* unstable mounting
* mechanical misalignment

---

## 🧭 Constraints Defined in This Step

* Rectangular pot geometry (parametric, not decorative)
* Grid-based mounting approach
* Separate wet and dry zones
* Fixed sensor positioning strategy
* Controlled water entry point

---

## ❌ Out of Scope (This Step)

* Final aesthetics or industrial design
* Multi-pot systems
* Water tank or pump housing
* Electronics enclosure design
* Advanced fluid control

---

## 📸 Visual References

See `/images` folder for:

* Concept render
* System diagrams
* Part breakdown

---

## 📌 Outcome

At the end of this step, we have:

* A clear modular architecture
* Defined mechanical constraints
* Locked MVP dimensions
* A structured foundation for CAD modeling

---

## ➡️ Next Step

**Mechanical Step 02 — OpenSCAD Architecture**

* Parameter system definition
* Module structure (pot, holder, clips)
* First functional 3D models
* Assembly preview

---
