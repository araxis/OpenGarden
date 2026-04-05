include <BOSL2/std.scad>

// ===================================
// OpenGarden - Simple Pot Holder
// Fixed for: Multiconnect - openGrid
// Grid-driven sizing
// Simplified and maintainable MVP version
// ===================================

$fn = 32;


// ----------------------------
// OpenGrid-driven sizing
// ----------------------------
gridPitch = 28;

// Holder / pot size in openGrid units
potUnitsX = 6;
potUnitsY = 6;
potUnitsZ = 5;

// Fit / tolerance
fitClearanceXY = 0.8;

// Derived pot opening size
potOpeningWidth  = potUnitsX * gridPitch - fitClearanceXY;
potOpeningDepth  = potUnitsY * gridPitch - fitClearanceXY;
potHeight        = potUnitsZ * gridPitch;


// ----------------------------
// Holder structure
// ----------------------------
frameWall       = 8;     // frame thickness
supportLip      = 6;     // bottom support lip height
backThickness   = 6.5;   // multiconnect back thickness
frontBeamHeight = 10;    // top/front stabilizer beam
cornerRadius    = 1;


// ----------------------------
// Multiconnect / openGrid slot settings
// ----------------------------
slotTolerance = 1.00;
slotQuickRelease = false;
dimpleScale = 1;
slotDepthMicroadjustment = 0;
onRampEnabled = true;
onRampHalfOffset = true;
onRampEveryXSlots = 1;
Multiconnect_Stop_Distance_From_Back = 13;


// ----------------------------
// Derived holder dimensions
// ----------------------------
holderWidth  = potOpeningWidth + frameWall * 2;
holderDepth  = potOpeningDepth + frameWall * 2;
holderHeight = potHeight + supportLip;

// Back plate snapped to grid
backWidth  = ceil(holderWidth / gridPitch) * gridPitch;
backHeight = ceil(holderHeight / gridPitch) * gridPitch;


// ----------------------------
// Main assembly
// ----------------------------
union() {
    // Pot holder frame
    translate([0, 0.01, 0])
        pot_holder_frame();

    // Back plate with openGrid multiconnect slots
    translate([-backWidth/2, 0.01, -supportLip])
        make_back_plate(
            backWidth = backWidth,
            backHeight = backHeight,
            backThickness = backThickness,
            distanceBetweenSlots = gridPitch
        );
}


// ----------------------------
// Pot holder frame
// Centered on X, extends forward in Y
// ----------------------------
module pot_holder_frame() {
    difference() {
        union() {
            // Top frame ring
            translate([-holderWidth/2, 0, potHeight - frameWall])
                frame_ring(holderWidth, holderDepth, frameWall, frameWall);

            // Bottom support frame
            translate([-holderWidth/2, 0, -supportLip])
                frame_ring(holderWidth, holderDepth, supportLip, frameWall);

            // 4 vertical corner posts
            corner_posts();

            // Rear wall beam tying frame into back plate
            translate([-holderWidth/2, 0, -supportLip])
                cuboid(
                    [holderWidth, frameWall, holderHeight + supportLip],
                    rounding = cornerRadius,
                    edges = FRONT,
                    except_edges = BOT,
                    anchor = FRONT + LEFT + BOT
                );

            // Small front top beam for stiffness
            translate([-holderWidth/2, holderDepth - frameWall, potHeight - frontBeamHeight])
                cuboid(
                    [holderWidth, frameWall, frontBeamHeight],
                    rounding = cornerRadius,
                    edges = FRONT,
                    except_edges = BOT,
                    anchor = FRONT + LEFT + BOT
                );
        }

        // Open front access cut
        translate([
            -potOpeningWidth/2,
            holderDepth - frameWall - 0.1,
            10
        ])
        cuboid(
            [potOpeningWidth, frameWall + 0.2, potHeight - 20],
            anchor = FRONT + LEFT + BOT
        );
    }
}


// ----------------------------
// Frame ring helper
// ----------------------------
module frame_ring(outerW, outerD, height, wall) {
    difference() {
        cuboid(
            [outerW, outerD, height],
            rounding = cornerRadius,
            edges = FRONT,
            except_edges = BOT,
            anchor = FRONT + LEFT + BOT
        );

        translate([wall, wall, -0.1])
            cuboid(
                [outerW - 2 * wall, outerD - 2 * wall, height + 0.2],
                anchor = FRONT + LEFT + BOT
            );
    }
}


// ----------------------------
// 4 corner posts
// ----------------------------
module corner_posts() {
    postH = potHeight - frameWall;

    // back-left
    translate([-holderWidth/2, 0, -supportLip])
        cuboid(
            [frameWall, frameWall, postH + supportLip],
            anchor = FRONT + LEFT + BOT
        );

    // back-right
    translate([holderWidth/2 - frameWall, 0, -supportLip])
        cuboid(
            [frameWall, frameWall, postH + supportLip],
            anchor = FRONT + LEFT + BOT
        );

    // front-left
    translate([-holderWidth/2, holderDepth - frameWall, -supportLip])
        cuboid(
            [frameWall, frameWall, postH + supportLip],
            anchor = FRONT + LEFT + BOT
        );

    // front-right
    translate([holderWidth/2 - frameWall, holderDepth - frameWall, -supportLip])
        cuboid(
            [frameWall, frameWall, postH + supportLip],
            anchor = FRONT + LEFT + BOT
        );
}


// ============================
// Back plate + Multiconnect
// Only for openGrid spacing = 28
// ============================
module make_back_plate(backWidth, backHeight, backThickness, distanceBetweenSlots)
{
    slotCount = floor(backWidth / distanceBetweenSlots);

    difference() {
        translate([0, -backThickness, 0])
            cuboid(
                size = [backWidth, backThickness, backHeight],
                rounding = 1,
                edges = FRONT,
                except_edges = BOT,
                anchor = FRONT + LEFT + BOT,
                $fn = 24
            );

        // Center slots across back plate
        for (slotNum = [0 : 1 : slotCount - 1]) {
            translate([
                distanceBetweenSlots/2
                    + (backWidth/distanceBetweenSlots - slotCount) * distanceBetweenSlots/2
                    + slotNum * distanceBetweenSlots,
                -2.35 + slotDepthMicroadjustment,
                backHeight - Multiconnect_Stop_Distance_From_Back
            ])
            multiConnectSlotTool(backHeight + supportLip);
        }
    }
}


// ============================
// Original multiconnect slot tool
// Kept because fit matters
// ============================
module multiConnectSlotTool(totalHeight) {
    distanceOffset = onRampHalfOffset ? gridPitch / 2 : 0;

    scale(slotTolerance)
    let (slotProfile = [[0,0],[10.15,0],[10.15,1.2121],[7.65,3.712],[7.65,5],[0,5]])
    difference() {
        union() {
            // Round top
            rotate([90,0,0])
                rotate_extrude($fn=50)
                    polygon(points = slotProfile);

            // Long slot
            rotate([180,0,0])
                linear_extrude(height = totalHeight + 1)
                    union() {
                        polygon(points = slotProfile);
                        mirror([1,0,0]) polygon(points = slotProfile);
                    }

            // Optional on-ramp
            if (onRampEnabled)
                for (y = [1 : onRampEveryXSlots : totalHeight / gridPitch])
                    translate([0, -5, (-y * gridPitch) + distanceOffset])
                        rotate([-90,0,0])
                            cylinder(h = 5, r1 = 12, r2 = 10.15);
        }

        // Locking dimple
        if (!slotQuickRelease)
            scale(dimpleScale)
                rotate([90,0,0])
                    rotate_extrude($fn=50)
                        polygon(points = [[0,0],[0,1.5],[1.5,0]]);
    }
}