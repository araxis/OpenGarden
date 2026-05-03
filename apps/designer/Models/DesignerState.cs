using System.Globalization;
using System.Text;

namespace OpenGarden.Designer.Models;

public sealed class DesignerState
{
    public string OutputMode { get; set; } = "Print Layout";
    public bool OpenGridSupport { get; set; }
    public int SubtractSlots { get; set; } = 0;
    public string SlotPlacement { get; set; } ="Center";
    public string RenderQuality { get; set; } = "Preview";
    public double PrintSpacing { get; set; } = 20;

    public double PotHeight { get; set; } = 100;
    public double PotWidth { get; set; } = 70;
    public double PotDepth { get; set; } = 70;
    public double ReservoirRatio { get; set; } = 0.3;

    public double SeatHeight { get; set; } = 5;
    public double WallThickness { get; set; } = 2;
    public double BaseThickness { get; set; } = 2;

    public string HolePattern { get; set; } = "Rectangle";
    public int HoleRows { get; set; } = 4;
    public int HoleColumns { get; set; } = 4;
    public double HoleDiameter { get; set; } = 5;
    public double HolePadding { get; set; } = 25;

    public string GridRows { get; set; } = "1*";
    public string GridColumns { get; set; } = "1*";
    public string DefaultFeature { get; set; } = FeatureTypes.Pot;
    public double GridWallThickness { get; set; } = 2;
    public List<CellFeatureConfig> CellFeatures { get; } = [new()];

    public string GridLabel => $"{TrackCount(GridRows)} x {TrackCount(GridColumns)}";

    public string PotVisualStyle =>
        $"--pot-w:{Math.Clamp(PotWidth / 110, 0.55, 1.8):0.00};--pot-d:{Math.Clamp(PotDepth / 110, 0.55, 1.8):0.00};--pot-h:{Math.Clamp(PotHeight / 160, 0.55, 1.8):0.00};";

    public string GenerateScadConfig() => string.Join(Environment.NewLine, new[]
    {
        $"Output_Mode = \"{OutputMode}\";",
        $"OpenGrid_Support = {Bool(OpenGridSupport)};",
        $"Subtracted_Slots = {SubtractSlots};",
        $"Slot_Placement = \"{SlotPlacement}\";",
        $"Print_Spacing = {Format(PrintSpacing)};",
        $"Render_Quality = \"{RenderQuality}\";",
        $"Pot_Height = {Format(PotHeight)};",
        $"Pot_Width = {Format(PotWidth)};",
        $"Pot_Depth = {Format(PotDepth)};",
        $"Reservoir_Height_Ratio = {Format(ReservoirRatio)};",
        $"Seat_Height = {Format(SeatHeight)};",
        $"Wall_Thickness = {Format(WallThickness)};",
        $"Base_Thickness = {Format(BaseThickness)};",
        $"Hole_Pattern = \"{HolePattern}\";",
        $"Hole_Rows = {HoleRows};",
        $"Hole_Columns = {HoleColumns};",
        $"Hole_Diameter = {Format(HoleDiameter)};",
        $"Hole_Area_Padding = {Format(HolePadding)};",
        $"Grid_Row_Sizes = \"{Escape(GridRows)}\";",
        $"Grid_Column_Sizes = \"{Escape(GridColumns)}\";",
        $"Cell_Default_Feature = \"{DefaultFeature}\";",
        $"Grid_Cell_Spans = \"{Escape(GenerateCellSpans())}\";",
        $"Grid_Wall_Thickness = {Format(GridWallThickness)};",
        $"Cell_Feature_Overrides = \"{Escape(GenerateFeatureOverrides())}\";"
    });

    public string GeneratePreviewScad()
    {
        var featureScad = GeneratePreviewFeatureScad();

        return $$"""
        $fn = 32;
        width = {{Format(PotWidth)}};
        depth = {{Format(PotDepth)}};
        height = {{Format(PotHeight)}};
        reservoir_height = height * {{Format(ReservoirRatio)}};
        insert_height = height - reservoir_height;
        wall = {{Format(WallThickness)}};
        base = {{Format(BaseThickness)}};
        rows = {{TrackCount(GridRows)}};
        cols = {{TrackCount(GridColumns)}};
        module open_box(w, d, h) {
          difference() {
            cube([w, d, h]);
            translate([wall, wall, base])
              cube([w - wall * 2, d - wall * 2, h]);
          }
        }

        module grid_walls(w, d, h) {
          cell_w = (w - wall * 2) / cols;
          cell_d = (d - wall * 2) / rows;
          for (x = [1:cols - 1])
            translate([wall + cell_w * x - wall / 2, wall, base])
              cube([wall, d - wall * 2, h - base]);
          for (y = [1:rows - 1])
            translate([wall, wall + cell_d * y - wall / 2, base])
              cube([w - wall * 2, wall, h - base]);
        }

        function hole_offset(index, count, span) =
          count <= 1 ? 0 : -span / 2 + index * span / (count - 1);

        module drain_holes_cell(x0, y0, w, d, rows, cols, diameter, padding) {
          span_x = w - padding;
          span_y = d - padding;
          for (x = [1:cols])
            for (y = [1:rows])
              translate([
                x0 + w / 2 + hole_offset(x - 1, cols, span_x),
                y0 + d / 2 + hole_offset(y - 1, rows, span_y),
                -0.2
              ])
                cylinder(h = base + 0.4, d = diameter);
        }

        module fill_tube_cell(x0, y0, w, d, clearance) {
          translate([x0 + clearance, y0 + clearance, -0.2])
            cube([w - clearance * 2, d - clearance * 2, base + 0.4]);
        }

        module wick_port_cell(x0, y0, w, d, diameter) {
          translate([x0 + w / 2, y0 + d / 2, -0.2])
            cylinder(h = base + 0.4, d = diameter);
        }

        module lid_lip_cell(x0, y0, w, d, lip_depth, lip_width) {
          translate([x0 + lip_width, y0 + lip_width, insert_height - lip_depth])
            cube([w - lip_width * 2, d - lip_width * 2, lip_depth + 0.2]);
        }

        difference() {
          union() {
            open_box(width, depth, insert_height);
            grid_walls(width, depth, insert_height);
        {{featureScad.Additive}}
          }
        {{featureScad.Subtractive}}
        }
        """;
    }

    public string GenerateCellSpans() =>
        string.Join(";", CellFeatures
            .Where(feature => feature.SpanRows > 1 || feature.SpanColumns > 1)
            .Select(feature => $"{feature.Row},{feature.Column}={feature.SpanRows}x{feature.SpanColumns}"));

    public string GenerateFeatureOverrides() =>
        string.Join("; ", CellFeatures.Select(feature => feature.ToOverrideText()));

    private PreviewFeatureScad GeneratePreviewFeatureScad()
    {
        var additive = new StringBuilder();
        var subtractive = new StringBuilder();

        additive.AppendLine("            // feature additions are intentionally lightweight in browser preview");
        subtractive.AppendLine("          cell_w = (width - wall * 2) / cols;");
        subtractive.AppendLine("          cell_d = (depth - wall * 2) / rows;");

        foreach (var gap in CellFeatures.Where(feature => feature.SpanRows > 1 || feature.SpanColumns > 1))
        {
            var startRow = Math.Max(1, gap.Row);
            var startColumn = Math.Max(1, gap.Column);
            var spanRows = Math.Max(1, gap.SpanRows);
            var spanColumns = Math.Max(1, gap.SpanColumns);

            for (var columnOffset = 1; columnOffset < spanColumns; columnOffset++)
            {
                subtractive.AppendLine(CultureInfo.InvariantCulture,
                    $"          translate([wall + cell_w * {startColumn - 1 + columnOffset} - wall / 2, wall + cell_d * {startRow - 1}, base - 0.1])");
                subtractive.AppendLine(CultureInfo.InvariantCulture,
                    $"            cube([wall, cell_d * {spanRows}, insert_height - base + 0.2]);");
            }

            for (var rowOffset = 1; rowOffset < spanRows; rowOffset++)
            {
                subtractive.AppendLine(CultureInfo.InvariantCulture,
                    $"          translate([wall + cell_w * {startColumn - 1}, wall + cell_d * {startRow - 1 + rowOffset} - wall / 2, base - 0.1])");
                subtractive.AppendLine(CultureInfo.InvariantCulture,
                    $"            cube([cell_w * {spanColumns}, wall, insert_height - base + 0.2]);");
            }
        }

        foreach (var feature in PreviewCells())
        {
            var row = Math.Max(1, feature.Row);
            var column = Math.Max(1, feature.Column);
            var spanRows = Math.Max(1, feature.SpanRows);
            var spanColumns = Math.Max(1, feature.SpanColumns);
            var x = $"wall + cell_w * {column - 1}";
            var y = $"wall + cell_d * {row - 1}";
            var w = $"cell_w * {spanColumns}";
            var d = $"cell_d * {spanRows}";

            switch (feature.Feature)
            {
                case FeatureTypes.DrainHoles:
                    subtractive.AppendLine(CultureInfo.InvariantCulture,
                        $"          drain_holes_cell({x}, {y}, {w}, {d}, {feature.DrainHoles.Rows}, {feature.DrainHoles.Columns}, {Format(feature.DrainHoles.Diameter)}, {Format(feature.DrainHoles.Padding)});");
                    break;
                case FeatureTypes.FillTube:
                    subtractive.AppendLine(CultureInfo.InvariantCulture,
                        $"          fill_tube_cell({x}, {y}, {w}, {d}, {Format(feature.FillTube.Clearance)});");
                    break;
                case FeatureTypes.WickPort:
                    subtractive.AppendLine(CultureInfo.InvariantCulture,
                        $"          wick_port_cell({x}, {y}, {w}, {d}, {Format(feature.WickPort.Diameter)});");
                    break;
                case FeatureTypes.LidLip:
                    subtractive.AppendLine(CultureInfo.InvariantCulture,
                        $"          lid_lip_cell({x}, {y}, {w}, {d}, {Format(feature.LidLip.Depth)}, {Format(feature.LidLip.Width)});");
                    break;
            }
        }

        return new PreviewFeatureScad(additive.ToString().TrimEnd(), subtractive.ToString().TrimEnd());
    }

    private IEnumerable<CellFeatureConfig> PreviewCells()
    {
        var explicitCells = CellFeatures
            .Where(feature => feature.Feature != FeatureTypes.Box)
            .ToList();

        if (DefaultFeature is not (FeatureTypes.Pot or FeatureTypes.DrainHoles))
        {
            return explicitCells;
        }

        var occupied = CellFeatures
            .Select(feature => (feature.Row, feature.Column))
            .ToHashSet();

        var cells = new List<CellFeatureConfig>(explicitCells);
        for (var row = 1; row <= TrackCount(GridRows); row++)
        {
            for (var column = 1; column <= TrackCount(GridColumns); column++)
            {
                if (!occupied.Contains((row, column)))
                {
                    cells.Add(new CellFeatureConfig { Row = row, Column = column, Feature = FeatureTypes.DrainHoles });
                }
            }
        }

        return cells;
    }

    public static int TrackCount(string value) =>
        string.IsNullOrWhiteSpace(value) ? 1 : value.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Length;

    public static string Format(double value) => value.ToString("0.###", CultureInfo.InvariantCulture);

    private static string Bool(bool value) => value ? "true" : "false";

    private static string Escape(string value) => value.Replace("\\", "\\\\").Replace("\"", "\\\"");
}

public sealed record PreviewFeatureScad(string Additive, string Subtractive);


public sealed class RendererResult
{
    public bool Ok { get; set; }
    public string Message { get; set; } = "";
    public string DownloadUrl { get; set; } = "";
    public string FileName { get; set; } = "";
    public int ByteLength { get; set; }
    public double ElapsedMs { get; set; }
}

public sealed class CellFeatureConfig
{
    public int Row { get; set; } = 1;
    public int Column { get; set; } = 1;
    public int SpanRows { get; set; } = 1;
    public int SpanColumns { get; set; } = 1;
    public string Feature { get; set; } = FeatureTypes.DrainHoles;

    public DrainHoleFeature DrainHoles { get; set; } = new();
    public LidLipFeature LidLip { get; set; } = new();
    public WickPortFeature WickPort { get; set; } = new();
    public FillTubeFeature FillTube { get; set; } = new();

    public string ToOverrideText()
    {
        var builder = new StringBuilder($"{Row},{Column}: {FeatureTypes.ToAlias(Feature)}");

        foreach (var parameter in Parameters())
        {
            builder.Append(',').Append(parameter);
        }

        return builder.ToString();
    }

    private IEnumerable<string> Parameters() => Feature switch
    {
        FeatureTypes.DrainHoles =>
        [
            $"pattern={DrainHoles.PatternAlias}",
            $"rows={DrainHoles.Rows}",
            $"cols={DrainHoles.Columns}",
            $"diameter={DesignerState.Format(DrainHoles.Diameter)}",
            $"padding={DesignerState.Format(DrainHoles.Padding)}"
        ],
        FeatureTypes.LidLip =>
        [
            $"depth={DesignerState.Format(LidLip.Depth)}",
            $"width={DesignerState.Format(LidLip.Width)}"
        ],
        FeatureTypes.WickPort =>
        [
            $"diameter={DesignerState.Format(WickPort.Diameter)}",
            $"rim={WickPort.Rim.ToString().ToLowerInvariant()}"
        ],
        FeatureTypes.FillTube =>
        [
            $"clearance={DesignerState.Format(FillTube.Clearance)}"
        ],
        _ => []
    };
}

public sealed class DrainHoleFeature
{
    public string Pattern { get; set; } = "Rectangle";
    public string PatternAlias => Pattern == "Circle" ? "C" : "R";
    public int Rows { get; set; } = 4;
    public int Columns { get; set; } = 4;
    public double Diameter { get; set; } = 5;
    public double Padding { get; set; } = 25;
}

public sealed class LidLipFeature
{
    public double Depth { get; set; } = 2;
    public double Width { get; set; } = 8;
}

public sealed class WickPortFeature
{
    public double Diameter { get; set; } = 10;
    public bool Rim { get; set; } = true;
}

public sealed class FillTubeFeature
{
    public double Clearance { get; set; } = 0.8;
}

public static class FeatureTypes
{
    public const string Pot = "Pot";
    public const string Box = "Box";
    public const string FillTube = "FillTube";
    public const string WickPort = "WickPort";
    public const string DrainHoles = "DrainHoles";
    public const string LidLip = "LidLip";

    public static readonly string[] All = [DrainHoles, LidLip, WickPort, FillTube, Box];
    public static readonly string[] Defaults = [Pot, Box, FillTube, WickPort];

    public static string ToAlias(string feature) => feature switch
    {
        DrainHoles => "dh",
        LidLip => "ll",
        WickPort => "wp",
        FillTube => "ft",
        Box => "b",
        _ => feature
    };
}
